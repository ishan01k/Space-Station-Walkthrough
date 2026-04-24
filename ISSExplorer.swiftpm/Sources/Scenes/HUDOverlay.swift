 import SpriteKit
 import SceneKit


 class HUDOverlay {
    
     private var sceneSize: CGSize
     private var interactionButton: SKLabelNode!
    
     var onButtonTap: (() -> Void)?
     private var recordButton: SKLabelNode!
     private var sitButton: SKLabelNode!
    
     var onRecordTap: (() -> Void)?
     var onSitTap: (() -> Void)?
    
     private var zeroGButton: SKLabelNode!
     var onZeroGTap: (() -> Void)?
     private var evaStatusLabel: SKLabelNode?
     private var upButton: SKShapeNode!
     private var downButton: SKShapeNode!
    
     var isUpPressed: Bool = false
     var isDownPressed: Bool = false
     var currentRoom: String = ""
     private var minimapContainer: SKNode!
     private var minimapDot: SKShapeNode!
     private let mapScale: CGFloat = 4.5
     private var isMinimapEnlarged = false
     private var lastAstronautPos: SCNVector3 = SCNVector3Zero
     weak var scnViewRef: SCNView?
    
     private var missionsOverlayNode: SKNode?
     private var missionsSearchText: String = ""
     private weak var missionsSearchField: UITextField?
     private var missionsScrollOffset: CGFloat = 0
     var isMissionsExplorerVisible: Bool { missionsOverlayNode != nil }
     var dataPanelContainer: SKNode!
     
     private var roomNameLabelNode: SKLabelNode?
     private var dataLabelNode: SKLabelNode?
     private var zeroGBgNode: SKShapeNode?
     private var recordBgNode: SKShapeNode?
     init(sceneSize: CGSize) {
         self.sceneSize = sceneSize
     }
     private func runOnMain(_ block: @escaping () -> Void) {
         if Thread.isMainThread {
             block()
         } else {
             DispatchQueue.main.async {
                 block()
             }
         }
     }

     private func createRoundedRectPath(rect: CGRect, radius: CGFloat) -> CGMutablePath {
         let path = CGMutablePath()
         path.move(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
         path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))
         path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY), tangent2End: CGPoint(x: rect.maxX, y: rect.maxY - radius), radius: radius)
         path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + radius))
         path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY), tangent2End: CGPoint(x: rect.maxX - radius, y: rect.minY), radius: radius)
         path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.minY))
         path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY), tangent2End: CGPoint(x: rect.minX, y: rect.minY + radius), radius: radius)
         path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
         path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY), tangent2End: CGPoint(x: rect.minX + radius, y: rect.maxY), radius: radius)
         path.closeSubpath()
         return path
     }

     private func createRoundedRectShape(size: CGSize, radius: CGFloat) -> SKShapeNode {
         let rect = CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
         return SKShapeNode(path: createRoundedRectPath(rect: rect, radius: radius))
     }
     func addToScene(_ scene: SKScene) {
         sceneSize = scene.size
         interactionButton = createSideButton(name: "interactButton", text: "Action", yOffset: 410)
         scene.addChild(interactionButton)
         recordButton = createSideButton(name: "recordButton", text: "🔴 Start Recording", yOffset: 350)
         scene.addChild(recordButton)
         sitButton = createSideButton(name: "sitButton", text: "🪑 Sit Down", yOffset: 410)
         scene.addChild(sitButton)
         zeroGButton = createZeroGButton()
         self.zeroGBgNode = zeroGButton.childNode(withName: "zeroGBg") as? SKShapeNode
         scene.addChild(zeroGButton)
         self.recordBgNode = recordButton?.childNode(withName: "sideBg") as? SKShapeNode
         setupMinimap(in: scene)
         setupDataPanel(in: scene)
         setupManeuverButtons(in: scene)
     }

    
     private func setupManeuverButtons(in scene: SKScene) {
         let btnSize = CGSize(width: 80, height: 80)
         let xPos: CGFloat = scene.size.width - 100
         let bottomY: CGFloat = 120
         upButton = createManeuverButton(name: "maneuverUp", symbol: "▲", size: btnSize)
         upButton.position = CGPoint(x: xPos, y: bottomY + 100)
         scene.addChild(upButton)
         downButton = createManeuverButton(name: "maneuverDown", symbol: "▼", size: btnSize)
         downButton.position = CGPoint(x: xPos, y: bottomY)
         scene.addChild(downButton)
         hideManeuverButtons()
     }
     private func createManeuverButton(name: String, symbol: String, size: CGSize) -> SKShapeNode {
         let btn = createRoundedRectShape(size: size, radius: 12)
         btn.name = name
         btn.fillColor = UIColor(white: 0.1, alpha: 0.7)
         btn.strokeColor = UIColor(white: 0.5, alpha: 0.8)
         btn.lineWidth = 2
         btn.zPosition = 300
         let label = SKLabelNode(text: symbol)
         label.fontName = "AvenirNext-Bold"
         label.fontSize = 40
         label.fontColor = .white
         label.verticalAlignmentMode = .center
         label.horizontalAlignmentMode = .center
         btn.addChild(label)
         return btn
     }
     func showManeuverButtons() {
         upButton.isHidden = false
         downButton.isHidden = false
     }
     func hideManeuverButtons() {
         upButton.isHidden = true
         downButton.isHidden = true
         isUpPressed = false
         isDownPressed = false
     }
     private func setupDataPanel(in scene: SKScene) {
         dataPanelContainer = SKNode()
         dataPanelContainer.position = CGPoint(x: sceneSize.width - 20, y: sceneSize.height - 20)
         dataPanelContainer.zPosition = 100
         scene.addChild(dataPanelContainer)
         let panelWidth: CGFloat = 300
         let panelHeight: CGFloat = 310
         let bg = SKShapeNode(rect: CGRect(x: -panelWidth, y: -panelHeight, width: panelWidth, height: panelHeight), cornerRadius: 4)
         bg.fillColor = UIColor(white: 0.1, alpha: 0.95) 
         bg.strokeColor = UIColor(white: 0.4, alpha: 0.8) 
         bg.lineWidth = 1.5
         bg.name = "dataPanelBg"
         dataPanelContainer.addChild(bg)
         let headerBg = SKShapeNode(rect: CGRect(x: -panelWidth, y: -30, width: panelWidth, height: 30), cornerRadius: 4)
         headerBg.fillColor = UIColor(white: 0.2, alpha: 0.95)
         headerBg.strokeColor = .clear
         dataPanelContainer.addChild(headerBg)
         let roomLabel = SKLabelNode(text: "ISS MAIN CORRIDOR")
         roomLabel.fontName = "Courier-Bold"
         roomLabel.fontSize = 16
         roomLabel.fontColor = .white
         roomLabel.horizontalAlignmentMode = .center
         roomLabel.verticalAlignmentMode = .center
         roomLabel.position = CGPoint(x: -panelWidth / 2, y: -15)
         roomLabel.name = "roomNameLabel"
         dataPanelContainer.addChild(roomLabel)
         let dataLabel = SKLabelNode(text: "> _")
         dataLabel.fontName = "Courier"
         dataLabel.fontSize = 14
         dataLabel.fontColor = UIColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1) 
         dataLabel.horizontalAlignmentMode = .left
         dataLabel.verticalAlignmentMode = .top
         dataLabel.position = CGPoint(x: -panelWidth + 15, y: -45)
         dataLabel.name = "dataLabel"
         dataLabel.numberOfLines = 0
         dataLabel.preferredMaxLayoutWidth = panelWidth - 30
         dataPanelContainer.addChild(dataLabel)
         
         self.roomNameLabelNode = roomLabel
         self.dataLabelNode = dataLabel
     }
     func updateRoomLabel(text: String) {
         roomNameLabelNode?.text = text
     }
     private var currentDataText: String = ""
     func updateDataPanel(texts: [String]) {
         guard let label = dataLabelNode else { return }
         let fullText = "> " + texts.joined(separator: "\n> ")
         if fullText == currentDataText { return }
         currentDataText = fullText
         typewriterAnimate(label: label, fullText: fullText)
     }
     private func typewriterAnimate(label: SKLabelNode, fullText: String) {
         label.removeAllActions()
         label.text = ""
         let chars = Array(fullText)
         var actions: [SKAction] = []
         for (i, _) in chars.enumerated() {
             let reveal = SKAction.run { [weak label] in
                 label?.text = String(chars.prefix(i + 1)) + "█"  
             }
             actions.append(reveal)
             actions.append(SKAction.wait(forDuration: 0.035))
         }
         let finalSet = SKAction.run { [weak label] in label?.text = fullText + "\n> _" }
         actions.append(finalSet)
         label.run(SKAction.sequence(actions))
     }
     func clearDataPanel() {
         if let label = dataLabelNode {
             label.removeAllActions()
             label.text = "> _"
         }
     }
     func setDataPanelInstant(texts: [String]) {
         guard let label = dataLabelNode else { return }
         let fullText = "> " + texts.joined(separator: "\n> ")
         if fullText == currentDataText { return }
         currentDataText = fullText
         label.removeAllActions()
         label.text = fullText + "\n> _"
     }
     private func setupMinimap(in scene: SKScene) {
         minimapContainer = SKNode()
         minimapContainer.position = CGPoint(x: 20, y: sceneSize.height - 20) 
         minimapContainer.alpha = 0.7 
         scene.addChild(minimapContainer)
         let bg = SKShapeNode(rect: CGRect(x: 0, y: -200, width: 170, height: 200), cornerRadius: 8)
         bg.fillColor = UIColor(white: 0, alpha: 0.3)
         bg.strokeColor = .clear
         minimapContainer.addChild(bg)
         let mapCenter = CGPoint(x: 85, y: -100) 
         func drawRoom(center: (Float, Float), size: (Float, Float), fill: UIColor = .gray) {
             let cx = CGFloat(center.1) * mapScale 
             let cy = CGFloat(center.0) * mapScale 
             let w = CGFloat(size.1) * mapScale
             let h = CGFloat(size.0) * mapScale
             let rect = SKShapeNode(rectOf: CGSize(width: w, height: h))
             rect.position = CGPoint(x: mapCenter.x + cx, y: mapCenter.y + cy)
             rect.fillColor = fill
             rect.strokeColor = .white
             rect.lineWidth = 1.0
             minimapContainer.addChild(rect)
         }
         drawRoom(center: (0, 0), size: (40, 8), fill: UIColor(white: 0.6, alpha: 1))
         let pathColor = UIColor(white: 0.55, alpha: 1)
         let roomColor = UIColor(white: 0.5, alpha: 1)
         for x: Float in [-12, -5, 3, 10, 17] { drawRoom(center: (x, -6), size: (3, 4), fill: pathColor) }
         for x: Float in [-7, 7] { drawRoom(center: (x, 6), size: (3, 4), fill: pathColor) }
         drawRoom(center: (-12, -12), size: (8, 8), fill: roomColor)
         drawRoom(center: (-5, -11.5), size: (6, 7), fill: roomColor)
         drawRoom(center: (3, -12), size: (8, 8), fill: roomColor)
         drawRoom(center: (10, -12), size: (6, 8), fill: roomColor)
         drawRoom(center: (17, -12), size: (8, 8), fill: roomColor)
         drawRoom(center: (-7, 12), size: (9, 8), fill: roomColor)
         drawRoom(center: (7, 12), size: (9, 8), fill: roomColor)
         minimapDot = SKShapeNode(circleOfRadius: 3.5)
         minimapDot.fillColor = .white
         minimapDot.strokeColor = .black
         minimapDot.lineWidth = 1.0
         minimapDot.position = mapCenter
         minimapContainer.addChild(minimapDot)
     }
     func updateMinimap(astronautPosition pos: SCNVector3) {
         lastAstronautPos = pos
         guard let dot = minimapDot else { return }
         let mapCenter = CGPoint(x: 85, y: -100)
         let mapX = mapCenter.x + CGFloat(pos.z) * mapScale
         let mapY = mapCenter.y + CGFloat(pos.x) * mapScale
         dot.position = CGPoint(x: mapX, y: mapY)
     }
     private func showEnlargedMinimap(in scene: SKScene) {
         guard !isMinimapEnlarged else { return }
         isMinimapEnlarged = true
         let overlay = SKShapeNode(rectOf: sceneSize)
         overlay.fillColor = UIColor(white: 0, alpha: 0.78)
         overlay.strokeColor = .clear
         overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
         overlay.zPosition = 600
         overlay.name = "bigMapOverlay"
         scene.addChild(overlay)
         let panelW: CGFloat = min(sceneSize.width - 60, 520)
         let panelH: CGFloat = min(sceneSize.height - 120, 480)
         let panel = createRoundedRectShape(size: CGSize(width: panelW, height: panelH), radius: 16)
         panel.fillColor = UIColor(red: 0.04, green: 0.06, blue: 0.14, alpha: 0.97)
         panel.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.8)
         panel.lineWidth = 2
         panel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
         panel.zPosition = 601
         panel.name = "bigMapPanel"
         scene.addChild(panel)
         let title = SKLabelNode(text: "ISS STATION MAP")
         title.fontName = "Courier-Bold"
         title.fontSize = 18
         title.fontColor = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1)
         title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 + panelH / 2 - 28)
         title.zPosition = 602
         title.name = "bigMapTitle"
         scene.addChild(title)
         let usableW = panelW - 40  
         let usableH = panelH - 90  
         let bigScale = min(usableW / 34.0, usableH / 42.0)
         let mapOrigin = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 - 5)
         let mapNode = SKNode()
         mapNode.position = mapOrigin
         mapNode.zPosition = 602
         mapNode.name = "bigMapNode"
    
         let corridorColor = UIColor(white: 0.55, alpha: 1)
         let passageColor  = UIColor(white: 0.45, alpha: 1)
         let roomFill      = UIColor(red: 0.15, green: 0.28, blue: 0.55, alpha: 1)
         let roomStroke    = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 0.9)
         func bigRect(cx: Float, cz: Float, w: Float, h: Float, fill: UIColor, stroke: UIColor = roomStroke) {
             let mx = CGFloat(cz) * bigScale
             let my = CGFloat(cx) * bigScale
             let rect = createRoundedRectShape(size: CGSize(width: CGFloat(h) * bigScale, height: CGFloat(w) * bigScale), radius: 3)
             rect.position = CGPoint(x: mx, y: my)
             rect.fillColor = fill
             rect.strokeColor = stroke
             rect.lineWidth = 1.5
             mapNode.addChild(rect)
         }
         func bigLabel(_ text: String, cx: Float, cz: Float, fontSize: CGFloat = 11) {
             let lbl = SKLabelNode(text: text)
             lbl.fontName = "Courier-Bold"
             lbl.fontSize = fontSize
             lbl.fontColor = UIColor(red: 0.8, green: 0.95, blue: 1.0, alpha: 1)
             lbl.horizontalAlignmentMode = .center
             lbl.verticalAlignmentMode = .center
             lbl.numberOfLines = 0
             lbl.preferredMaxLayoutWidth = 80
             lbl.position = CGPoint(x: CGFloat(cz) * bigScale, y: CGFloat(cx) * bigScale)
             lbl.zPosition = 1
             mapNode.addChild(lbl)
         }
         bigRect(cx: 0, cz: 0, w: 40, h: 8, fill: corridorColor, stroke: .clear)
         for x: Float in [-12, -5, 3, 10, 17] {
             bigRect(cx: x, cz: -6, w: 3, h: 4, fill: passageColor, stroke: .clear)
         }
         for x: Float in [-7, 7] {
             bigRect(cx: x, cz: 6, w: 3, h: 4, fill: passageColor, stroke: .clear)
         }
         bigRect(cx: -12, cz: -12, w: 8, h: 8, fill: roomFill)
         bigLabel("WINDOW\nROOM", cx: -12, cz: -12)
         bigRect(cx: -5, cz: -11.5, w: 6, h: 7, fill: roomFill)
         bigLabel("CREW\nQUARTERS", cx: -5, cz: -11.5)
         bigRect(cx: 3, cz: -12, w: 8, h: 8, fill: roomFill)
         bigLabel("ZERO-G\nLAB", cx: 3, cz: -12)
         bigRect(cx: 10, cz: -12, w: 6, h: 8, fill: roomFill)
         bigLabel("SPACE\nWALK", cx: 10, cz: -12)
         bigRect(cx: 17, cz: -12, w: 8, h: 8, fill: roomFill)
         bigLabel("EXPLORE\nMISSIONS", cx: 17, cz: -12)
         bigRect(cx: -7, cz: 12, w: 9, h: 8, fill: roomFill)
         bigLabel("RESEARCH\nLAB", cx: -7, cz: 12)
         bigRect(cx: 7, cz: 12, w: 9, h: 8, fill: roomFill)
         bigLabel("COMMAND\n& CTRL", cx: 7, cz: 12)
         let dot = SKShapeNode(circleOfRadius: 6)
         dot.fillColor = UIColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 1)
         dot.strokeColor = .white
         dot.lineWidth = 1.5
         dot.name = "bigMapDot"
         let pos = lastAstronautPos
         dot.position = CGPoint(x: CGFloat(pos.z) * bigScale, y: CGFloat(pos.x) * bigScale)
         dot.run(.repeatForever(.sequence([
             .scale(to: 1.4, duration: 0.5),
             .scale(to: 1.0, duration: 0.5)
         ])))
         mapNode.addChild(dot)
         let youLabel = SKLabelNode(text: "▲ YOU")
         youLabel.fontName = "Courier-Bold"
         youLabel.fontSize = 8
         youLabel.fontColor = UIColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 1)
         youLabel.position = CGPoint(x: CGFloat(pos.z) * bigScale, y: CGFloat(pos.x) * bigScale - 14)
         youLabel.zPosition = 1
         mapNode.addChild(youLabel)
         let hint = SKLabelNode(text: "Tap anywhere to close")
         hint.fontName = "AvenirNext-Regular"
         hint.fontSize = 13
         hint.fontColor = UIColor(white: 0.5, alpha: 1)
         hint.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 - panelH / 2 + 18)
         hint.zPosition = 603
         hint.name = "bigMapHint"
         scene.addChild(hint)
         
         scene.addChild(mapNode)
     }
     private func hideEnlargedMinimap(in scene: SKScene) {
         guard isMinimapEnlarged else { return }
         isMinimapEnlarged = false
         let names = ["bigMapOverlay", "bigMapPanel", "bigMapTitle", "bigMapNode", "bigMapHint"]
         for name in names { scene.childNode(withName: name)?.removeFromParent() }
     }
     private func createZeroGButton() -> SKLabelNode {
         let btn = SKLabelNode(text: "🚀 Zero-G")
         btn.name = "zeroGButton"
         btn.fontName = "AvenirNext-Medium"
         btn.fontSize = 17
         btn.fontColor = .white
         btn.horizontalAlignmentMode = .center
         btn.verticalAlignmentMode = .center
         btn.position = CGPoint(x: sceneSize.width - 180, y: sceneSize.height - 400)
         btn.zPosition = 200
         btn.isHidden = true
         let bg = createRoundedRectShape(size: CGSize(width: 190, height: 40), radius: 8)
         bg.fillColor = UIColor(white: 0.08, alpha: 0.82)
         bg.strokeColor = .clear
         bg.name = "zeroGBg"
         bg.position = CGPoint(x: 0, y: 2)
         bg.zPosition = -1
         btn.addChild(bg)
         return btn
     }
     func showZeroGButton(isZeroGOn: Bool, action: @escaping () -> Void) {
         let emoji = isZeroGOn ? "🌍" : "🚀"
         let label = isZeroGOn ? " Zero-G OFF" : " Zero-G ON"
         zeroGButton.text = emoji + label
         zeroGButton.isHidden = false
         onZeroGTap = action
         zeroGButton.removeAction(forKey: "zeroGPulse")
         if isZeroGOn, let bg = zeroGBgNode {
             bg.strokeColor = UIColor(red: 0.2, green: 1.0, blue: 0.5, alpha: 1.0)
             let glowIn  = SKAction.customAction(withDuration: 0.7) { node, t in
                 (node as? SKShapeNode)?.glowWidth = CGFloat(t / 0.7) * 10
             }
             let glowOut = SKAction.customAction(withDuration: 0.7) { node, t in
                 (node as? SKShapeNode)?.glowWidth = (1 - CGFloat(t / 0.7)) * 10
             }
             bg.run(.repeatForever(.sequence([glowIn, glowOut])), withKey: "zeroGPulse")
         } else if let bg = zeroGBgNode {
             bg.removeAction(forKey: "zeroGPulse")
             bg.glowWidth = 0
             bg.strokeColor = UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 0.9)
         }
     }
     func hideZeroGButton() {
         zeroGButton.isHidden = true
         zeroGButton.removeAction(forKey: "zeroGPulse")
         onZeroGTap = nil
     }
     private func createSideButton(name: String, text: String, yOffset: CGFloat) -> SKLabelNode {
         let btn = SKLabelNode(text: text)
         btn.name = name
         btn.fontName = "AvenirNext-Medium"
         btn.fontSize = 17
         btn.fontColor = .white
         btn.horizontalAlignmentMode = .center
         btn.verticalAlignmentMode = .center
         btn.position = CGPoint(x: sceneSize.width - 180, y: sceneSize.height - yOffset)
         btn.zPosition = 200
         btn.isHidden = true
         let bg = createRoundedRectShape(size: CGSize(width: 205, height: 40), radius: 8)
         bg.fillColor = UIColor(white: 0.08, alpha: 0.82)
         bg.strokeColor = .clear
         bg.name = "sideBg"
         bg.position = CGPoint(x: 0, y: 2)
         bg.zPosition = -1
         btn.addChild(bg)
         return btn
     }
     func showRecordButton(text: String, action: @escaping () -> Void) {
         recordButton?.text = text
         recordButton?.isHidden = false
         if let bg = recordBgNode {
             let isRecording = text.contains("Stop")
             bg.strokeColor = isRecording
                 ? UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0)
                 : UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 0.9)
         }
         onRecordTap = action
     }
     func hideRecordButton() {
         recordButton?.isHidden = true
         onRecordTap = nil
     }
     func showSitButton(text: String, action: @escaping () -> Void) {
         sitButton?.text = text
         sitButton?.isHidden = false
         onSitTap = action
     }
     func hideSitButton() {
         sitButton?.isHidden = true
         onSitTap = nil
     }
     func showButton(text: String, action: @escaping () -> Void) {
         interactionButton?.text = text
         interactionButton?.isHidden = false
         onButtonTap = action
     }
     func hideButton() {
         interactionButton?.isHidden = true
         onButtonTap = nil
     }
     func showTemporaryMessage(_ text: String, duration: TimeInterval = 3.0) {
         let lbl = SKLabelNode(text: text)
         lbl.fontName = "AvenirNext-Bold"
         lbl.fontSize = 20
         lbl.fontColor = .white
         lbl.horizontalAlignmentMode = .center
         lbl.verticalAlignmentMode = .center
         lbl.numberOfLines = 0
         lbl.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 + 100)
         lbl.zPosition = 800
         guard let scene = interactionButton?.scene else { return } // Add lbl to scene first to get correct frame
         scene.addChild(lbl)
         let bg = createRoundedRectShape(size: CGSize(width: lbl.frame.width + 60, height: lbl.frame.height + 30), radius: 8)
         bg.fillColor = UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.9)
         bg.strokeColor = .white
         bg.lineWidth = 2
         bg.position = CGPoint(x: 0, y: 0)
         bg.zPosition = -1
         lbl.addChild(bg)
         
         lbl.alpha = 0
         let fadeIn = SKAction.fadeIn(withDuration: 0.3)
         let wait = SKAction.wait(forDuration: duration)
         let fadeOut = SKAction.fadeOut(withDuration: 0.5)
         let remove = SKAction.removeFromParent()
         lbl.run(.sequence([fadeIn, wait, fadeOut, remove]))
     }
     func showEVAStatus(o2Seconds: Int) {
         let mins = o2Seconds / 60
         let secs = o2Seconds % 60
         let timeStr = String(format: "%02d:%02d", mins, secs)
         let text = "🌌 EVA IN PROGRESS — O₂: \(timeStr)"
         if let existing = evaStatusLabel, existing.parent != nil {
             existing.text = text
             if o2Seconds <= 60 {
                 existing.fontColor = .red
                 (existing.childNode(withName: "evaBg") as? SKShapeNode)?.strokeColor = .red
             }
             return
         }
         let lbl = SKLabelNode(text: text)
         lbl.name = "evaStatusLabel"
         lbl.fontName = "Helvetica-Bold"
         lbl.fontSize = 20
         lbl.fontColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1) 
         lbl.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 110)
         lbl.zPosition = 250
         let bg = createRoundedRectShape(size: CGSize(width: 380, height: 35), radius: 8)
         bg.fillColor = UIColor(white: 0.1, alpha: 0.8)
         bg.strokeColor = UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.8)
         bg.lineWidth = 1.5
         bg.position = CGPoint(x: 0, y: 7)
         bg.name = "evaBg"
         lbl.addChild(bg)
         if let scene = interactionButton?.scene {
             scene.addChild(lbl)
         }
         evaStatusLabel = lbl
     }
     func hideEVAStatus() {
         evaStatusLabel?.removeFromParent()
         evaStatusLabel = nil
     }
         private var homeTitle: SKLabelNode?
         private var getStartedButton: SKLabelNode?
         var onGetStarted: (() -> Void)?
         func showHomeScreen(in scene: SKScene) {
             interactionButton?.isHidden = true
             minimapContainer.isHidden = true
             dataPanelContainer.isHidden = true
             let overlay = SKShapeNode(rectOf: sceneSize)
             overlay.fillColor = UIColor(white: 0, alpha: 0.55)
             overlay.strokeColor = .clear
             overlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
             overlay.zPosition = 490
             overlay.name = "homeOverlay"
             scene.addChild(overlay)
             let titleGlow = SKLabelNode(text: "AstroMe")
             titleGlow.fontName = "AvenirNext-Heavy"
             titleGlow.fontSize = 64
             titleGlow.fontColor = UIColor(red: 0.2, green: 0.55, blue: 1.0, alpha: 0.45)
             titleGlow.position = CGPoint(x: sceneSize.width / 2 + 1, y: sceneSize.height * 0.68 - 2)
             titleGlow.zPosition = 499
             titleGlow.name = "homeTitleGlow"
             scene.addChild(titleGlow)
             let title = SKLabelNode(text: "AstroMe")
             title.fontName = "AvenirNext-Heavy"
             title.fontSize = 64
             title.fontColor = .white
             title.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.68)
             title.zPosition = 500
             title.name = "homeTitle"
             scene.addChild(title)
             self.homeTitle = title
             let line = SKShapeNode()
             let linePath = CGMutablePath()
             linePath.move(to: CGPoint(x: sceneSize.width / 2 - 180, y: sceneSize.height * 0.66))
             linePath.addLine(to: CGPoint(x: sceneSize.width / 2 + 180, y: sceneSize.height * 0.66))
             line.path = linePath
             line.strokeColor = UIColor(red: 0.25, green: 0.6, blue: 1.0, alpha: 0.8)
             line.lineWidth = 1.5
             line.zPosition = 500
             line.name = "homeLine"
             scene.addChild(line)
             let subtitle = SKLabelNode(text: "Experience being an Astronaut in the space")
             subtitle.fontName = "AvenirNext-Medium"
             subtitle.fontSize = 17
             subtitle.fontColor = UIColor(red: 0.65, green: 0.82, blue: 1.0, alpha: 1)
             subtitle.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.63)
             subtitle.zPosition = 500
             subtitle.name = "homeSubtitle"
             scene.addChild(subtitle)
             let tagline = SKLabelNode(text: "Explore. Discover. Experience life aboard the ISS.")
             tagline.fontName = "AvenirNext-Regular"
             tagline.fontSize = 14
             tagline.fontColor = UIColor(white: 0.65, alpha: 1)
             tagline.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.595)
             tagline.zPosition = 500
             tagline.name = "homeTagline"
             scene.addChild(tagline)
             let startBtn = SKLabelNode(text: "Get Started")
             startBtn.name = "getStartedButton"
             startBtn.fontName = "AvenirNext-Bold"
             startBtn.fontSize = 22
             startBtn.fontColor = .white
             startBtn.verticalAlignmentMode = .center
             startBtn.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.44)
             startBtn.zPosition = 501
             let startBg = createRoundedRectShape(size: CGSize(width: 240, height: 56), radius: 28)
             startBg.fillColor = UIColor(red: 0.05, green: 0.38, blue: 0.9, alpha: 1)
             startBg.strokeColor = UIColor(red: 0.4, green: 0.75, blue: 1.0, alpha: 0.9)
             startBg.lineWidth = 2
             startBg.name = "startBg"
             startBg.position = CGPoint(x: 0, y: 0)
             startBg.zPosition = -1  
             startBtn.addChild(startBg)
             let chevron = SKLabelNode(text: "›")
             chevron.fontName = "Helvetica-Bold"
             chevron.fontSize = 24
             chevron.fontColor = UIColor(red: 0.5, green: 0.85, blue: 1.0, alpha: 1)
             chevron.position = CGPoint(x: 90, y: -1)
             startBtn.addChild(chevron)
             let glowIn  = SKAction.customAction(withDuration: 0.9) { node, t in
                 (node as? SKShapeNode)?.glowWidth = CGFloat(t / 0.9) * 8
             }
             let glowOut = SKAction.customAction(withDuration: 0.9) { node, t in
                 (node as? SKShapeNode)?.glowWidth = (1 - CGFloat(t / 0.9)) * 8
             }
             startBg.run(.repeatForever(.sequence([glowIn, glowOut])))
             scene.addChild(startBtn)
             self.getStartedButton = startBtn
             let featuresContainer = SKNode()
             featuresContainer.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.18)
             featuresContainer.name = "homeFeaturesContainer"
             featuresContainer.zPosition = 500
             scene.addChild(featuresContainer)
             let features = [
                 "🌍 Watch the Earth",
                 "👩‍🚀 Go on a Spacewalk",
                 "🔬 Research Science",
                 "☄️ Experience Zero-G",
                 "🚀 Learn Space Missions",
                 "🕹️ Command the Station"
             ]
             for (i, feature) in features.enumerated() {
                 let row = i / 2
                 let col = i % 2
                 let startX: CGFloat = -300
                 let xSpacing: CGFloat = 360
                 let startY: CGFloat = 80
                 let ySpacing: CGFloat = 65
                 let cx_item: CGFloat = startX + CGFloat(col) * xSpacing
                 let cy: CGFloat = startY - CGFloat(row) * ySpacing
                 let lbl = SKLabelNode(text: feature)
                 lbl.fontName = "AvenirNext-Medium"
                 lbl.fontSize = 26
                 lbl.fontColor = UIColor(white: 0.95, alpha: 1)
                 lbl.position = CGPoint(x: cx_item, y: cy)
                 lbl.horizontalAlignmentMode = .left 
                 featuresContainer.addChild(lbl)
             }
         }
         func hideHomeScreen() {
             let homeNodeNames = [
                 "homeOverlay", 
                 "homeTitleGlow", "homeTitle", "homeLine",
                 "homeSubtitle", "homeTagline", "getStartedButton", "homeHint",
                 "homeFeaturesContainer"
             ]
             if let scene = homeTitle?.scene ?? getStartedButton?.scene {
                 for name in homeNodeNames {
                     scene.childNode(withName: name)?.removeFromParent()
                 }
             }
             homeTitle = nil
             getStartedButton = nil
             minimapContainer.isHidden = false
             dataPanelContainer.isHidden = false
         }
         func handleTouchBegan(at location: CGPoint) {
             guard interactionButton != nil, upButton != nil, downButton != nil else { return }
             if !Thread.isMainThread {
                 runOnMain { [weak self] in
                     self?.handleTouchBegan(at: location)
                 }
                 return
             }
             if let btn = getStartedButton, !btn.isHidden {
                 let halfW: CGFloat = 140
                 let halfH: CGFloat = 35
                 let btnFrame = CGRect(
                     x: btn.position.x - halfW,
                     y: btn.position.y - halfH,
                     width: halfW * 2, height: halfH * 2
                 )
                 if btnFrame.contains(location) {
                     onGetStarted?()
                     return
                 }
             }
             let minimapFrame = CGRect(x: 20, y: sceneSize.height - 220, width: 175, height: 210)
             if minimapFrame.contains(location), let scene = minimapContainer?.scene {
                 if isMinimapEnlarged {
                     hideEnlargedMinimap(in: scene)
                 } else {
                     showEnlargedMinimap(in: scene)
                 }
                 return
             }
             if isMinimapEnlarged, let scene = minimapContainer?.scene {
                 hideEnlargedMinimap(in: scene)
                 return
             }
             if !(recordButton?.isHidden ?? true) {
                 let hitFrame = CGRect(
                     x: (recordButton?.position.x ?? 0) - 102.5,
                     y: (recordButton?.position.y ?? 0) - 18,
                     width: 205, 
                     height: 40
                 )
                 if hitFrame.contains(location) {
                     onRecordTap?()
                     return
                 }
             }
             if !(sitButton?.isHidden ?? true) {
                 let hitFrame = CGRect(
                     x: (sitButton?.position.x ?? 0) - 102.5,
                     y: (sitButton?.position.y ?? 0) - 18,
                     width: 205, 
                     height: 40
                 )
                 if hitFrame.contains(location) {
                     onSitTap?()
                     return
                 }
             }
             if !(zeroGButton?.isHidden ?? true) {
                 let hitFrame = CGRect(
                     x: (zeroGButton?.position.x ?? 0) - 100,
                     y: (zeroGButton?.position.y ?? 0) - 28,
                     width: 200, height: 56
                 )
                 if hitFrame.contains(location) {
                     onZeroGTap?()
                     return
                 }
             }
             if !(interactionButton?.isHidden ?? true) {
                 let btnCenterX = interactionButton?.position.x ?? 0
                 let btnCenterY = (interactionButton?.position.y ?? 0) + 8  
                 let hitFrame = CGRect(
                     x: btnCenterX - 125,
                     y: btnCenterY - 22,
                     width: 250, height: 45
                 )
                 if hitFrame.contains(location) {
                     onButtonTap?()
                     return
                 }
             }
             if !(upButton?.isHidden ?? true) {
                 if upButton?.contains(location) ?? false {
                     isUpPressed = true
                     upButton?.fillColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.8)
                     return
                 }
                 if downButton?.contains(location) ?? false {
                     isDownPressed = true
                     downButton?.fillColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.8)
                     return
                 }
             }
         }
         func handleTouchEnded(at location: CGPoint) {
             guard upButton != nil, downButton != nil else { return }
             isUpPressed = false
             isDownPressed = false
             upButton?.fillColor = UIColor(white: 0.1, alpha: 0.7)
             downButton?.fillColor = UIColor(white: 0.1, alpha: 0.7)
         }
     func showMissionsExplorer() {
         guard let scene = interactionButton?.scene, missionsOverlayNode == nil else { return }
         buildMissionsOverlay(in: scene)
     }
     func hideMissionsExplorer() {
         guard isMissionsExplorerVisible else { return }
         missionsOverlayNode?.removeFromParent()
         missionsOverlayNode = nil
         missionsSearchText = ""
         missionsScrollOffset = 0
         runOnMain { [weak self] in
             self?.missionsSearchField?.removeFromSuperview()
             self?.missionsSearchField = nil
         }
         if let gameOverlay = interactionButton?.scene as? GameOverlayScene {
             gameOverlay.joystick?.resetAllInput()
         }
     }
     private func buildMissionsOverlay(in scene: SKScene) {
         let overlay = SKNode()
         overlay.zPosition = 700
         overlay.name = "missionsOverlay"
         scene.addChild(overlay)
         missionsOverlayNode = overlay
         let panelW = sceneSize.width - 40
         let panelH = sceneSize.height - 40
         let cx = sceneSize.width / 2
         let panelBg = createRoundedRectShape(size: CGSize(width: panelW, height: panelH), radius: 18)
         panelBg.fillColor = UIColor(white: 0.04, alpha: 0.97)
         panelBg.strokeColor = UIColor(white: 0.2, alpha: 1.0)
         panelBg.lineWidth = 1.5
         panelBg.position = CGPoint(x: cx, y: sceneSize.height / 2)
         overlay.addChild(panelBg)
         let headerH: CGFloat = 52
         let headerBg = SKShapeNode(rectOf: CGSize(width: panelW, height: headerH))
         headerBg.fillColor = UIColor(white: 0.08, alpha: 1)
         headerBg.strokeColor = .clear
         headerBg.position = CGPoint(x: cx, y: sceneSize.height - 20 - headerH / 2)
         overlay.addChild(headerBg)
         let titleLabel = SKLabelNode(text: "🚀  SPACE MISSIONS EXPLORER")
         titleLabel.fontName = "Courier-Bold"
         titleLabel.fontSize = 16
         titleLabel.fontColor = .white
         titleLabel.horizontalAlignmentMode = .center
         titleLabel.verticalAlignmentMode = .center
         titleLabel.position = CGPoint(x: cx, y: sceneSize.height - 20 - headerH / 2)
         overlay.addChild(titleLabel)
         let closeBtn = SKLabelNode(text: "✕")
         closeBtn.fontName = "AvenirNext-Bold"
         closeBtn.fontSize = 22
         closeBtn.fontName = "AvenirNext-Medium"
         closeBtn.fontSize = 20
         closeBtn.fontColor = UIColor(white: 0.6, alpha: 1)
         closeBtn.horizontalAlignmentMode = .center
         closeBtn.verticalAlignmentMode = .center
         closeBtn.position = CGPoint(x: sceneSize.width - 20 - 34, y: sceneSize.height - 20 - headerH / 2 - 8)
         closeBtn.name = "missionsCloseBtn"
         overlay.addChild(closeBtn)
         let timelineTop = sceneSize.height - 20 - headerH - 24
         let timelineBottom: CGFloat = 40
         buildMissionsTimeline(in: overlay, cx: cx, panelW: panelW, top: timelineTop, bottom: timelineBottom)
     }

     private func visibleMissions() -> [SpaceMission] {
         var list = allSpaceMissions
         if !missionsSearchText.isEmpty {
             let q = missionsSearchText.lowercased()
             list = list.filter {
                 $0.name.lowercased().contains(q) ||
                 $0.agency.lowercased().contains(q) ||
                 $0.destination.lowercased().contains(q) ||
                 $0.year.description.contains(q)
             }
         }
         return list
     }
     private func buildMissionsTimeline(in overlay: SKNode, cx: CGFloat, panelW: CGFloat, top: CGFloat, bottom: CGFloat) {
         let missions = visibleMissions()
         let cardW: CGFloat = 200
         let cardH: CGFloat = 230
         let cardGap: CGFloat = 20
         let timelineH = top - bottom
        // let rect = CGRect(x: cx - panelW / 2 + 10, y: top - timelineH, width: panelW - 20, height: timelineH)
         //let radius: CGFloat = 8
         if missions.isEmpty {
             let emptyLabel = SKLabelNode(text: "> No results found")
             emptyLabel.fontName = "Courier"
             emptyLabel.fontSize = 15
             emptyLabel.fontColor = UIColor(red: 0.2, green: 0.9, blue: 0.5, alpha: 1)
             emptyLabel.horizontalAlignmentMode = .center
             emptyLabel.verticalAlignmentMode = .center
             emptyLabel.position = CGPoint(x: cx, y: bottom + timelineH / 2)
             emptyLabel.name = "missionsEmptyLabel"
             overlay.addChild(emptyLabel)
             return
         }
         let cropNode = SKCropNode()
         let mask = SKSpriteNode(color: .black, size: CGSize(width: panelW - 20, height: timelineH))
         mask.position = CGPoint(x: cx, y: bottom + timelineH / 2) // Place mask exactly where timeline belongs
         cropNode.maskNode = mask
         cropNode.position = CGPoint.zero // Keep origin pinned to overlay so children using absolute math stay put
         cropNode.name = "missionsScrollNode"
         cropNode.zPosition = 10
         overlay.addChild(cropNode)
         let scrollContent = SKNode()
         scrollContent.name = "missionsScrollContent"
         cropNode.addChild(scrollContent)
         let availableW = panelW - 80 
         var cols = Int((availableW + cardGap) / (cardW + cardGap))
         cols = max(1, min(3, cols)) 
         let rowH = cardH + 50
         let totalRows = Int(ceil(Double(missions.count) / Double(cols)))
         let contentH = CGFloat(totalRows) * rowH + 40
         let actualGridW = CGFloat(cols) * cardW + CGFloat(cols - 1) * cardGap
         let startX = cx - actualGridW / 2 + cardW / 2 
         let startY = top - 40 - cardH / 2 
         let spine = SKShapeNode()
         let spinePath = CGMutablePath()
         var positions: [CGPoint] = []
         for (i, mission) in missions.enumerated() {
             let row = i / cols
             let col = i % cols
             let actualCol = (row % 2 == 0) ? col : (cols - 1 - col)
             let x = startX + CGFloat(actualCol) * (cardW + cardGap)
             let y = startY - CGFloat(row) * rowH
             let pos = CGPoint(x: x, y: y)
             positions.append(pos)
             let card = buildMissionCard(mission: mission, cardW: cardW, cardH: cardH)
             card.position = pos
             scrollContent.addChild(card)
         }
         if positions.count > 1 {
             spinePath.move(to: positions[0])
             for i in 1..<positions.count {
                 spinePath.addLine(to: positions[i])
             }
         }
         spine.path = spinePath
         spine.strokeColor = UIColor(white: 0.4, alpha: 0.45)
         spine.lineWidth = 2.0
         spine.zPosition = -1 
         scrollContent.addChild(spine)
         let maxScroll = max(0, contentH - timelineH)
         missionsScrollOffset = max(0, min(maxScroll, missionsScrollOffset))
         scrollContent.position.y = missionsScrollOffset
         if maxScroll > 0 {
             let barX = cx + panelW / 2 - 25
             let trackRect = CGRect(x: -2, y: -timelineH / 2, width: 4, height: timelineH)
             let trackPath = CGPath(roundedRect: trackRect, cornerWidth: 2, cornerHeight: 2, transform: nil)
             let track = SKShapeNode(path: trackPath)
             track.fillColor = UIColor(white: 0.2, alpha: 0.5)
             track.strokeColor = .clear
             track.position = CGPoint(x: barX, y: bottom + timelineH / 2)
             track.name = "missionsScrollTrack"
             track.zPosition = 20
             overlay.addChild(track)

             let handleRatio = timelineH / contentH
             let handleH = max(40, (timelineH - 20) * handleRatio)
             let handleRect = CGRect(x: -3, y: -handleH / 2, width: 6, height: handleH)
             let handlePath = CGPath(roundedRect: handleRect, cornerWidth: 3, cornerHeight: 3, transform: nil)
             let handle = SKShapeNode(path: handlePath)
             handle.fillColor = UIColor(white: 0.6, alpha: 0.8)
             handle.strokeColor = .clear
             let scrollPct = missionsScrollOffset / maxScroll
             let handleSpace = max(0, (timelineH - 20) - handleH)
             let handleY = (bottom + timelineH / 2) + handleSpace / 2 - handleSpace * scrollPct
             handle.position = CGPoint(x: barX, y: handleY)
             handle.name = "missionsScrollHandle"
             handle.zPosition = 21
             overlay.addChild(handle)
         }
     }
     private func buildMissionCard(mission: SpaceMission, cardW: CGFloat, cardH: CGFloat) -> SKNode {
         let card = SKNode()
         card.name = "missionCard_\(mission.id)"

         // Shared background
         let bgRect = CGRect(x: -cardW / 2, y: -cardH / 2, width: cardW, height: cardH)
         let bgPath = CGPath(roundedRect: bgRect, cornerWidth: 12, cornerHeight: 12, transform: nil)
         let bg = SKShapeNode(path: bgPath)
         bg.fillColor = UIColor(red: 0.07, green: 0.1, blue: 0.16, alpha: 1)
         bg.strokeColor = UIColor(white: 0.3, alpha: 0.5)
         bg.lineWidth = 1.0
         bg.name = "cardBg"
         card.addChild(bg)

         // ── FRONT FACE ──────────────────────────────────────
         let front = SKNode()
         front.name = "cardFront"

         let tick = SKShapeNode()
         let tp = CGMutablePath()
         tp.move(to: CGPoint(x: 0, y: -cardH / 2))
         tp.addLine(to: CGPoint(x: 0, y: -cardH / 2 - 8))
         tick.path = tp
         tick.strokeColor = UIColor(white: 0.4, alpha: 0.6)
         tick.lineWidth = 1.5
         front.addChild(tick)

         let yearBg = SKShapeNode(path: CGPath(roundedRect: CGRect(x: -27, y: -9.5, width: 54, height: 19), cornerWidth: 9, cornerHeight: 9, transform: nil))
         yearBg.fillColor = UIColor(white: 0.2, alpha: 1)
         yearBg.strokeColor = .clear
         yearBg.position = CGPoint(x: 0, y: cardH / 2 - 66)
         front.addChild(yearBg)

         let yearLabel = SKLabelNode(text: "\(mission.year)")
         yearLabel.fontName = "Courier-Bold"
         yearLabel.fontSize = 11
         yearLabel.fontColor = UIColor(white: 0.9, alpha: 1)
         yearLabel.horizontalAlignmentMode = .center
         yearLabel.verticalAlignmentMode = .center
         yearLabel.position = yearBg.position
         front.addChild(yearLabel)

         let nameLabel = SKLabelNode(text: mission.name)
         nameLabel.fontName = "AvenirNext-Bold"
         nameLabel.fontSize = 12
         nameLabel.fontColor = .white
         nameLabel.horizontalAlignmentMode = .center
         nameLabel.verticalAlignmentMode = .top
         nameLabel.numberOfLines = 2
         nameLabel.preferredMaxLayoutWidth = cardW - 14
         nameLabel.position = CGPoint(x: 0, y: cardH / 2 - 84)
         front.addChild(nameLabel)

         let agencyLabel = SKLabelNode(text: mission.agency)
         agencyLabel.fontName = "AvenirNext-Medium"
         agencyLabel.fontSize = 10
         agencyLabel.fontColor = UIColor(white: 0.65, alpha: 1)
         agencyLabel.horizontalAlignmentMode = .center
         agencyLabel.verticalAlignmentMode = .center
         agencyLabel.position = CGPoint(x: 0, y: -cardH / 2 + 42)
         front.addChild(agencyLabel)

         let destLabel = SKLabelNode(text: "📍 \(mission.destination)")
         destLabel.fontName = "AvenirNext-Regular"
         destLabel.fontSize = 10
         destLabel.fontColor = UIColor(white: 0.45, alpha: 1)
         destLabel.horizontalAlignmentMode = .center
         destLabel.verticalAlignmentMode = .center
         destLabel.position = CGPoint(x: 0, y: -cardH / 2 + 26)
         front.addChild(destLabel)

         let tapHint = SKLabelNode(text: "tap for info ▸")
         tapHint.fontName = "AvenirNext-Regular"
         tapHint.fontSize = 9
         tapHint.fontColor = UIColor(white: 0.3, alpha: 1)
         tapHint.horizontalAlignmentMode = .center
         tapHint.verticalAlignmentMode = .center
         tapHint.position = CGPoint(x: 0, y: -cardH / 2 + 11)
         front.addChild(tapHint)

         card.addChild(front)

         // ── BACK FACE (hidden until tapped) ─────────────────
         let back = SKNode()
         back.name = "cardBack"
         back.isHidden = true

         let expandedBorder = SKShapeNode(path: bgPath)
         expandedBorder.fillColor = UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1)
         expandedBorder.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 1)
         expandedBorder.lineWidth = 2.0
         back.addChild(expandedBorder)

         let backName = SKLabelNode(text: "\(mission.name)  ·  \(mission.year)")
         backName.fontName = "AvenirNext-Bold"
         backName.fontSize = 12
         backName.fontColor = .white
         backName.horizontalAlignmentMode = .center
         backName.verticalAlignmentMode = .top
         backName.numberOfLines = 2
         backName.preferredMaxLayoutWidth = cardW - 16
         backName.position = CGPoint(x: 0, y: cardH / 2 - 14)
         back.addChild(backName)

         let sep = SKShapeNode()
         let sp = CGMutablePath()
         sp.move(to: CGPoint(x: -cardW / 2 + 12, y: cardH / 2 - 42))
         sp.addLine(to: CGPoint(x: cardW / 2 - 12, y: cardH / 2 - 42))
         sep.path = sp
         sep.strokeColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.4)
         sep.lineWidth = 1
         back.addChild(sep)

         let desc = SKLabelNode(text: mission.description)
         desc.fontName = "AvenirNext-Regular"
         desc.fontSize = 11
         desc.fontColor = UIColor(white: 0.85, alpha: 1)
         desc.horizontalAlignmentMode = .center
         desc.verticalAlignmentMode = .center
         desc.numberOfLines = 0
         desc.preferredMaxLayoutWidth = cardW - 16
         desc.position = CGPoint(x: 0, y: -2)
         back.addChild(desc)

         let closeHint = SKLabelNode(text: "◂ tap to close")
         closeHint.fontName = "AvenirNext-Regular"
         closeHint.fontSize = 9
         closeHint.fontColor = UIColor(red: 0.3, green: 0.6, blue: 0.9, alpha: 0.7)
         closeHint.horizontalAlignmentMode = .center
         closeHint.verticalAlignmentMode = .center
         closeHint.position = CGPoint(x: 0, y: -cardH / 2 + 11)
         back.addChild(closeHint)

         card.addChild(back)
         return card
     }

     private func addMissionsSearchField(searchBarY: CGFloat, panelW: CGFloat, cx: CGFloat) {
         guard let scnView = scnViewRef else { return }
         let fieldW = panelW - 40 - 8
         let fieldH: CGFloat = 36
         let fieldX = cx - fieldW / 2 + 20
        let fieldY = scnView.bounds.height - searchBarY - fieldH / 2
        runOnMain { [weak self] in
            guard let self = self else { return }
            let tf = UITextField(frame: CGRect(x: fieldX, y: fieldY, width: fieldW, height: fieldH))
            tf.backgroundColor = .clear
            tf.textColor = .white
            tf.font = UIFont(name: "AvenirNext-Regular", size: 14)
            tf.tintColor = UIColor(red: 0.4, green: 0.78, blue: 1.0, alpha: 1)
            tf.returnKeyType = .search
            tf.autocorrectionType = .no
            tf.autocapitalizationType = .none
            tf.tag = 9901
            scnView.addSubview(tf)
            self.missionsSearchField = tf
            tf.addTarget(self, action: #selector(self.missionsSearchChanged(_:)), for: .editingChanged)
        }
     }
     @objc private func missionsSearchChanged(_ sender: UITextField) {
         missionsSearchText = sender.text ?? ""
         if let overlay = missionsOverlayNode {
             overlay.childNode(withName: "missionsSearchPlaceholder")?.isHidden = !missionsSearchText.isEmpty
             if let lbl = overlay.childNode(withName: "missionsSearchActiveLabel") as? SKLabelNode {
                 lbl.text = missionsSearchText
             }
         }
         rebuildMissionsTimeline()
     }
     private func rebuildMissionsTimeline() {
         guard let overlay = self.missionsOverlayNode else { return }
         for name in ["missionsTimelineBg", "missionsScrollNode", "missionsEmptyLabel", "missionsScrollTrack", "missionsScrollHandle"] {
             overlay.childNode(withName: name)?.removeFromParent()
         }
         let headerH: CGFloat = 52
         let panelW = self.sceneSize.width - 40
         let cx = self.sceneSize.width / 2
         let topY = self.sceneSize.height - 20 - headerH - 24
         self.buildMissionsTimeline(in: overlay, cx: cx, panelW: panelW, top: topY, bottom: 40)
     }
    
     private var missionsScrollStartOffset: CGFloat = 0 
     private var isDraggingScrollbar = false 
     @discardableResult
     func handleMissionsTouchBegan(at location: CGPoint) -> Bool {
         if !Thread.isMainThread {
             runOnMain { [weak self] in
                 _ = self?.handleMissionsTouchBegan(at: location)
             }
             return true
         }
         
         missionsScrollStartOffset = missionsScrollOffset
         let headerH: CGFloat = 52
         
         let closeCX = sceneSize.width - 20 - 34
         let closeCY = sceneSize.height - 20 - headerH / 2
         if CGRect(x: closeCX - 28, y: closeCY - 26, width: 56, height: 52).contains(location) {
             hideMissionsExplorer()
             return true
         }
         if let overlay = missionsOverlayNode,
            let cropNode = overlay.childNode(withName: "missionsScrollNode") as? SKCropNode,
            let scrollContent = cropNode.childNode(withName: "missionsScrollContent"),
            let skScene = scrollContent.scene {
             let inContent = scrollContent.convert(location, from: skScene)
             let cardW: CGFloat = 200
             let cardH: CGFloat = 230
             for child in scrollContent.children {
                 if child.name?.starts(with: "missionCard_") == true {
                     let rect = CGRect(x: child.position.x - cardW/2, y: child.position.y - cardH/2, width: cardW, height: cardH)
                     if rect.contains(inContent) {
                         guard let name = child.name else { continue }
                         let id = name.replacingOccurrences(of: "missionCard_", with: "")
                        if visibleMissions().first(where: { $0.id == id }) != nil {
                            runOnMain {
                                self.missionsSearchField?.resignFirstResponder()
                            }
                            // Toggle front/back visibility directly — no rebuild needed
                            let front = child.childNode(withName: "cardFront")
                            let back  = child.childNode(withName: "cardBack")
                            let isNowExpanded = front?.isHidden == false
                            front?.isHidden = isNowExpanded
                            back?.isHidden  = !isNowExpanded
                            return true
                         }
                     }
                 }
             }
         }
         runOnMain { [weak self] in
             self?.missionsSearchField?.resignFirstResponder()
         }
         if let overlay = missionsOverlayNode, let handle = overlay.childNode(withName: "missionsScrollHandle") {
             let hitRect = handle.frame.insetBy(dx: -15, dy: -5)
             if hitRect.contains(location) {
                 isDraggingScrollbar = true
                 return true
             }
         }
         return true  
     }
     @discardableResult
     func handleMissionsTouchMoved(at location: CGPoint, delta: CGPoint) -> Bool {
         guard isMissionsExplorerVisible else { return false }
         if let overlay = missionsOverlayNode,
            let cropNode = overlay.childNode(withName: "missionsScrollNode") as? SKCropNode,
            let scrollContent = cropNode.childNode(withName: "missionsScrollContent") {
             let panelW = sceneSize.width - 40
             let missions = visibleMissions()
             let cardW: CGFloat = 200
             let cardGap: CGFloat = 20
             let cardH: CGFloat = 230
             let headerH: CGFloat = 52
             let topY = sceneSize.height - 20 - headerH - 24
             let bottomY: CGFloat = 40
             let timelineH = topY - bottomY
             let availableW = panelW - 80
             var cols = Int((availableW + cardGap) / (cardW + cardGap))
             cols = max(1, min(3, cols))
             let rowH = cardH + 50
             let totalRows = Int(ceil(Double(missions.count) / Double(cols)))
             let contentH = CGFloat(totalRows) * rowH + 40
             guard contentH > 0 else { return true }
             let maxScroll = max(0, contentH - timelineH)
             if isDraggingScrollbar {
                 let handleRatio = timelineH / contentH
                 let handleH = max(40, (timelineH - 20) * handleRatio)
                 let handleSpace = (timelineH - 20) - handleH
                 if handleSpace > 0 {
                     let scrollDelta = -delta.y * (maxScroll / handleSpace)
                     missionsScrollOffset = max(0, min(maxScroll, missionsScrollOffset + scrollDelta))
                 }
             } else {
                 missionsScrollOffset = max(0, min(maxScroll, missionsScrollOffset + delta.y))
             }
             scrollContent.position.y = missionsScrollOffset
             if maxScroll > 0, let handle = overlay.childNode(withName: "missionsScrollHandle") {
                 let handleRatio = timelineH / contentH
                 let handleH = max(40, (timelineH - 20) * handleRatio)
                 let scrollPct = missionsScrollOffset / maxScroll
                 let handleSpace = (timelineH - 20) - handleH
                 let handleY = (bottomY + timelineH / 2) + handleSpace / 2 - handleSpace * scrollPct
                 handle.position.y = handleY
             }
         }
         return true
     }
     @discardableResult
     func handleMissionsTouchEnded() -> Bool {
         isDraggingScrollbar = false
         return isMissionsExplorerVisible
     }
 }
