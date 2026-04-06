import SceneKit
import SpriteKit


class RoomInteractionManager: NSObject {
    
    let scene: SCNScene
    let astronaut: AstronautNode
    let hud: HUDOverlay
    
    weak var scnView: SCNView?
    weak var joystick: JoystickOverlay?
    
    var currentRoom: String = ""
    var zeroGEnabled = false
    var suitedUp = false
    var spaceWalkActive = false
    var untetheredTime: TimeInterval = 0 
    var lastUntetheredUpdate: TimeInterval = 0
    
    var isRecording = false
    var isSitting = false
    var isSleeping = false
    var isCommanding = false
    var depressurizationStep: Int = 0  
    var hatch1Open = false
    var hatch2Open = false
    var cableAttached = false
    
    private var evaO2Seconds: Int = 480
    private var evaTimerTask: DispatchWorkItem?
    private var savedAstronautPos = SCNVector3Zero
    private var savedFacingAngle: Float = 0
    
    private var tetherNode: SCNNode?
    private let tetherMaxLength: Float = 150.0
    private let tetherAnchor = SCNVector3(10.0, 2.2, -19.0)
    
    private var windowRoomVisitCount  = 0
    private var scienceLabVisitCount  = 0
    private var logRoomSessionCount   = 0
    private var totalRecordingCount   = 0
    
    private var commandPanelAge: TimeInterval = 0
    private let commandPanelRefreshInterval: TimeInterval = 8.0
    
    init(scene: SCNScene, astronaut: AstronautNode, hud: HUDOverlay, scnView: SCNView) {
        self.scene = scene
        self.astronaut = astronaut
        self.hud = hud
        self.scnView = scnView
        super.init()
    }
    func checkRoomBoundaries(position: SCNVector3) {
        var expectedRoom = ""
        let x = position.x
        let z = position.z
        if z < -5.0 {
            if spaceWalkActive && z < -25.0 {
                expectedRoom = "OuterSpace" 
            } else {
                if x > -15.5 && x < -8.5 { expectedRoom = "WindowRoomTrigger" }
                else if x > -8.5 && x < -1.5 { expectedRoom = "LogTrigger" }
                else if x > -0.5 && x < 6.5 { expectedRoom = "ZeroGTrigger" }
                else if x > 6.5 && x < 13.5 { 
                    if z > -13.0 { expectedRoom = "SuitUpTrigger" }
                    else if z > -15.8 { expectedRoom = "Hatch1Trigger" } 
                    else if z > -16.8 { expectedRoom = "ChamberTrigger" }
                    else { expectedRoom = "Hatch2Trigger" } 
                }
                else if x > 13.5 && x < 20.5 { expectedRoom = "TechTrigger" }
            }
        } else if z > 4.5 {
            if x > -11.5 && x < -2.5 { expectedRoom = "ScienceLabTrigger" }    
            else if x > 2.5 && x < 11.5 { expectedRoom = "CommandControlTrigger" } 
        }
        if expectedRoom != currentRoom {
            let previousRoom = currentRoom
            currentRoom = expectedRoom 
            if !previousRoom.isEmpty { exitRoom(trigger: previousRoom) }
            if !expectedRoom.isEmpty { enterRoom(trigger: expectedRoom) }
        }
        let currentTime = ProcessInfo.processInfo.systemUptime
        if spaceWalkActive && !cableAttached {
            if lastUntetheredUpdate == 0 {
                lastUntetheredUpdate = currentTime
            } else {
                let dt = currentTime - lastUntetheredUpdate
                untetheredTime += dt
                lastUntetheredUpdate = currentTime
                if untetheredTime >= 3.0 {
                    astronaut.physicsBody?.velocity = SCNVector3Zero
                    astronaut.position = SCNVector3(15.0, 0.9, -18.5)
                    astronaut.facingAngle = 0 
                    hud.showTemporaryMessage("WARNING: Untethered drift detected.\nAuto-recovery engaged.", duration: 3.0)
                    untetheredTime = 0
                    lastUntetheredUpdate = 0
                }
            }
        } else {
            untetheredTime = 0
            lastUntetheredUpdate = 0
        }
    }
    private func roomInfoLines(for trigger: String) -> [String] {
        switch trigger {
        case "CorridorTrigger":
            return ["ISS EXPEDITION — YOUR MISSION",
                    "Explore 7 modules of the ISS.",
                    "Science Lab: run experiments.",
                    "Space Walk: suit up & do an EVA.",
                    "Command Room: monitor status.",
                    "Zero-G Lab: toggle microgravity.",
                    "Window Room: observe Earth.",
                    "Log Room: record crew entries.",
                    "Mission Explorer: view historical missions."]
        case "WindowRoomTrigger":
            return ["CUPOLA MODULE",
                    "Windows for Earth obs.",
                    "Installed by STS-130, 2010.",
                    "Best view on the ISS."]
        case "LogTrigger":
            return ["CREW QUARTERS",
                    "Private sleep pods & log desk.",
                    "Crew logs daily mission data.",
                    "CCTV monitors all areas."]
        case "ZeroGTrigger":
            return ["ZERO-G LAB",
                    "Microgravity research area.",
                    "Objects float at 0 g.",
                    "Toggle gravity below."]
        case "SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger":
            return airlockStepInstructions()
        case "TechTrigger":
            return ["MISSION EXPLORER",
                    "Electronics & systems rack.",
                    "Explore humanity's space missions.",
                    "Tap 'Explore Missions' to begin."]
        case "ScienceLabTrigger":
            return ["ISS RESEARCH LAB",
                    "NASA's primary research node.",
                    "MSG glovebox & MELFI freezer.",
                    "Over 400 experiments run here."]
        case "CommandControlTrigger":
            return ["COMMAND & CONTROL",
                    "Robotics & navigation hub.",
                    "Canadarm2 operated here.",
                    "Comm links to Mission Control."]
        default:
            return []
        }
    }
    func enterRoom(trigger: String) {
        toggleRoomLight(for: trigger, isOn: true)
        hud.updateRoomLabel(text: formatRoomName(trigger))
        switch trigger {
        case "WindowRoomTrigger":  windowRoomVisitCount += 1
        case "ScienceLabTrigger": scienceLabVisitCount += 1
        case "LogTrigger":         logRoomSessionCount += 1
        default: break
        }
        if trigger == "CommandControlTrigger" {
            commandPanelAge = commandPanelRefreshInterval  
            hud.updateDataPanel(texts: commandRoomStatusLines())
        } else {
            let lines = roomInfoLines(for: trigger)
            if !lines.isEmpty { hud.updateDataPanel(texts: lines) }
        }
        switch trigger {
        case "ZeroGTrigger":
            updateZeroGButton()
        case "SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger":
            updateAirlockButton() 
        case "TechTrigger":
            if !spaceWalkActive {
                hud.showButton(text: "🚀 Explore Missions") { [weak self] in
                    self?.hud.showMissionsExplorer()
                }
            }
        default:
            break
        }
    }
    func exitRoom(trigger: String) {
        hud.hideButton()
        hud.hideZeroGButton()
        hud.hideMissionsExplorer()
        hud.updateRoomLabel(text: "ISS MAIN CORRIDOR")
        toggleRoomLight(for: trigger, isOn: false)
        let corridorLines = roomInfoLines(for: "CorridorTrigger")
        hud.updateDataPanel(texts: corridorLines)
    }
    private func formatRoomName(_ trigger: String) -> String {
        switch trigger {
        case "CorridorTrigger":       return "ISS MAIN CORRIDOR"
        case "WindowRoomTrigger":     return "CUPOLA MODULE"
        case "LogTrigger":            return "CREW QUARTERS"
        case "ZeroGTrigger":          return "ZERO-G LAB"
        case "SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger":        return "SPACE WALK ROOM"
        case "TechTrigger":           return "MISSION EXPLORER"
        case "ScienceLabTrigger":     return "ISS RESEARCH LAB"
        case "CommandControlTrigger": return "COMMAND & CONTROL"
        default: return "UNKNOWN SECTOR"
        }
    }
    private func toggleRoomLight(for trigger: String, isOn: Bool) {
        let lightName: String
        switch trigger {
        case "WindowRoomTrigger":    lightName = "WindowRoomLight"
        case "LogTrigger":           lightName = "LogRoomLight"
        case "ZeroGTrigger":         lightName = "ZeroGRoomLight"
        case "SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger":       lightName = "AirlockRoomLight"
        case "TechTrigger":          lightName = "TechRoomLight"
        case "ScienceLabTrigger":    lightName = "ScienceLabRoomLight"
        case "CommandControlTrigger":lightName = "CommandControlRoomLight"
        default: return
        }
        scene.rootNode.enumerateChildNodes { (node, stop) in
            if node.name == lightName {
                node.isHidden = !isOn
            }
        }
    }
    func updateZeroGButton() {
        hud.showZeroGButton(isZeroGOn: zeroGEnabled) { [weak self] in
            guard let self = self else { return }
            self.zeroGEnabled.toggle()
            if self.zeroGEnabled {
                self.scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
                self.astronaut.physicsBody?.velocity = SCNVector3(
                    self.astronaut.physicsBody?.velocity.x ?? 0,
                    1.0,
                    self.astronaut.physicsBody?.velocity.z ?? 0
                )
                self.astronaut.startFloatAnimation()
            } else {
                self.scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
                self.astronaut.stopFloatAnimation()
            }
            self.updateZeroGButton()
        }
    }
    func airlockStepInstructions() -> [String] {
        var steps: [String] = ["SPACE WALK PREPARATION", ""]
        if !suitedUp {
            steps.append("STEP 1: Wear Space Suit")
            steps.append("Status: REQUIRED")
        } else if !hatch1Open && currentRoom == "SuitUpTrigger" {
            steps.append("STEP 2: Open Inner Hatch")
            steps.append("Status: COMPLETED (Suit Donned)")
        } else if hatch1Open && (currentRoom == "SuitUpTrigger" || currentRoom == "Hatch1Trigger") {
            steps.append("STEP 3: Enter Crew Lock Chamber")
            steps.append("Status: Inner hatch is open.")
        } else if hatch1Open && (currentRoom == "ChamberTrigger" || currentRoom == "Hatch2Trigger") {
            steps.append("STEP 4: Close Inner Hatch")
            steps.append("Status: REQUIRED for pressure seal.")
        } else if !cableAttached {
            steps.append("STEP 5: Attach Safety Tether")
            steps.append("Status: REQUIRED for EVA safety.")
        } else if depressurizationStep < 2 {
            steps.append("STEP 6: Depressurize Chamber")
            steps.append("Status: Ready to vent.")
        } else if depressurizationStep == 2 {
            steps.append("STEP 7: Wait for Vacuum")
            steps.append("Status: VENTING IN PROGRESS...")
        } else if depressurizationStep == 3 {
            steps.append("STEP 8: Begin EVA")
            steps.append("Status: CHAMBER DEPRESSURIZED.")
        } else if spaceWalkActive {
            steps.append("EVA MISSION IN PROGRESS")
            steps.append("Status: Tether active. Monitor O2.")
        }
        return steps
    }
    func commandRoomStatusLines() -> [String] {
        var lines: [String] = ["STATION STATUS REPORT", ""]
        let zeroGStatus = zeroGEnabled ? "ACTIVE — 0.0 m/s²" : "STANDBY — 9.8 m/s²"
        lines.append("ZERO-G LAB: \(zeroGStatus)")
        let logStatus: String
        if isSleeping        { logStatus = "Crew in sleep pod" }
        else if isSitting    { logStatus = "Crew at desk" }
        else if isRecording  { logStatus = "⬤ REC in progress" }
        else if logRoomSessionCount > 0 { logStatus = "Idle (\(totalRecordingCount) logs)" }
        else                 { logStatus = "Not visited" }
        lines.append("LOG ROOM: \(logStatus)")
        let sciStatus = scienceLabVisitCount == 0
            ? "No crew activity"
            : "Visited \(scienceLabVisitCount)x — experiments nominal"
        lines.append("ISS RESEARCH LAB: \(sciStatus)")
        let winStatus = windowRoomVisitCount == 0
            ? "No observations logged"
            : "\(windowRoomVisitCount) observation(s) logged"
        lines.append("CUPOLA: \(winStatus)")
        var airlockStatus = "Sealed — nominal"
        if spaceWalkActive {
            airlockStatus = "🌌 EVA in progress"
        } else if suitedUp && cableAttached {
            airlockStatus = "Ready for Outer Hatch"
        } else if suitedUp {
            airlockStatus = "Crew suited up"
        }
        lines.append("SPACE WALK: \(airlockStatus)")
        return lines
    }
    func updateAirlockButton() {
        hud.hideButton() 
        switch currentRoom {
        case "SuitUpTrigger":
            if !suitedUp {
                hud.showButton(text: "🧑‍🚀 Wear Space Suit") { [weak self] in
                    guard let self = self else { return }
                    self.suitedUp = true
                    self.applySpaceSuit()
                    self.updateAirlockButton()
                }
            } else {
                hud.showButton(text: "✅ Suit Donned") {}
            }
        case "Hatch1Trigger":
            if !hatch1Open {
                if hatch2Open {
                    hud.showButton(text: "⚠️ Close Outer Hatch First") {}
                } else {
                    hud.showButton(text: "🔓 Open Inner Hatch") { [weak self] in
                        self?.hatch1Open = true
                        self?.animateHatch1(open: true)
                        self?.updateAirlockButton()
                    }
                }
            } else {
                hud.showButton(text: "🔒 Close Inner Hatch") { [weak self] in
                    self?.hatch1Open = false
                    self?.animateHatch1(open: false)
                    self?.updateAirlockButton()
                }
            }
        case "ChamberTrigger":
            if hatch1Open {
                hud.showButton(text: "⚠️ Close Inner Hatch First") {}
            } else if !cableAttached {
                hud.showButton(text: "🔗 Attach Safety Tether") { [weak self] in
                    self?.cableAttached = true
                    self?.updateAirlockButton()
                }
            } else {
                hud.showButton(text: "✅ Tether Attached") {}
            }
        case "Hatch2Trigger":
            if !hatch1Open && cableAttached && suitedUp {
                if !spaceWalkActive {
                    if depressurizationStep < 2 {
                        hud.showButton(text: "💨 Depressurize Chamber") { [weak self] in
                            self?.startDepressurization()
                        }
                    } else if depressurizationStep == 2 {
                        hud.showButton(text: "⌛ Depressurizing...") {}
                    } else if depressurizationStep == 3 {
                        hud.showButton(text: "🚀 Open Outer Hatch — EVA") { [weak self] in
                            guard let self = self else { return }
                            self.hatch2Open = true
                            self.spaceWalkActive = true
                            self.depressurizationStep = 4 
                            self.animateHatch2(open: true)
                            self.scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
                            self.astronaut.physicsBody?.damping = 0.05
                            self.astronaut.physicsBody?.angularDamping = 0.95
                            self.astronaut.startFloatAnimation()
                            self.startEVATimer()
                            self.hud.showManeuverButtons()
                            self.updateAirlockButton()
                        }
                    }
                } else {
                    hud.showButton(text: "🔙 Return to Airlock") { [weak self] in
                        self?.endSpaceWalk()
                    }
                }
            } else if hatch1Open {
                hud.showButton(text: "⚠️ Inner Hatch Must Be Closed") {}
            } else if !cableAttached {
                hud.showButton(text: "⚠️ Tether Required") {}
            } else if !suitedUp {
                hud.showButton(text: "⚠️ Suit Required") {}
            }
        default:
            break
        }
        if ["SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger"].contains(currentRoom) {
            hud.setDataPanelInstant(texts: airlockStepInstructions())
        }
    }
    func animateHatch1(open: Bool) {
        guard let hatchNode = scene.rootNode.childNode(withName: "AirlockHatch1", recursively: true) else { return }
        let targetAngle: CGFloat = open ? -.pi / 2 : 0
        let action = SCNAction.rotateTo(x: 0, y: targetAngle, z: 0, duration: 1.0, usesShortestUnitArc: true)
        action.timingMode = .easeInEaseOut
        hatchNode.runAction(action, forKey: "hatch1Anim")
    }
    func animateHatch2(open: Bool) {
        guard let hatchNode = scene.rootNode.childNode(withName: "AirlockHatch2", recursively: true) else { return }
        let targetAngle: CGFloat = open ? -.pi / 2 : 0
        let action = SCNAction.rotateTo(x: 0, y: targetAngle, z: 0, duration: 1.5, usesShortestUnitArc: true)
        action.timingMode = .easeInEaseOut
        hatchNode.runAction(action, forKey: "hatch2Anim")
    }
    func startDepressurization() {
        depressurizationStep = 2
        updateAirlockButton()
        blinkWarningLights(on: true)
        hud.updateDataPanel(texts: [
            "⚠️ DEPRESSURIZATION INITIATED",
            "Venting atmosphere to space...",
            "Pressure: 101.3 kPa -> 0.0 kPa",
            "Estimated time: 5 seconds"
        ])
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
            guard let self = self, self.depressurizationStep == 2 else {
                t.invalidate()
                return
            }
            self.createVentingEffect()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            timer.invalidate()
            guard let self = self, self.currentRoom == "Hatch2Trigger" || self.currentRoom == "ChamberTrigger" else { return }
            self.depressurizationStep = 3 
            self.blinkWarningLights(on: false)
            self.hud.updateDataPanel(texts: [
                "✅ VACUUM ESTABLISHED",
                "Chamber pressure: 0.0 kPa",
                "Crew is ready for egress."
            ])
            self.updateAirlockButton()
        }
    }
    private func createVentingEffect() {
        for _ in 0..<15 {
            let sphere = SCNSphere(radius: 0.12)
            let mat = SCNMaterial()
            mat.diffuse.contents = UIColor(white: 0.95, alpha: 0.6)
            mat.lightingModel = .constant
            sphere.firstMaterial = mat
            let node = SCNNode(geometry: sphere)
            let rx = Float.random(in: -0.5...0.5)
            let ry = Float.random(in: -0.5...0.5)
            let rz = Float.random(in: -0.5...0.5)
            node.position = SCNVector3(15.0 + rx, 2.0 + ry, -20.0 + rz)
            scene.rootNode.addChildNode(node)
            let dx = CGFloat.random(in: -0.3...0.3)
            let dy = CGFloat.random(in: -0.3...0.3)
            let dz = CGFloat.random(in: -2.5...(-1.5))
            let move = SCNAction.moveBy(x: dx, y: dy, z: dz, duration: 2.0)
            let scale = SCNAction.scale(to: 4.0, duration: 2.0)
            let fade = SCNAction.fadeOut(duration: 2.0)
            node.runAction(.group([move, scale, fade])) {
                node.removeFromParentNode()
            }
        }
    }
    func applySpaceSuit() {
        astronaut.childNode(withName: "EVAHelmet", recursively: false)?.removeFromParentNode()
        let helmetGeo = SCNSphere(radius: 0.38)
        let vm = SCNMaterial()
        vm.diffuse.contents = UIColor(red: 0.85, green: 0.68, blue: 0.08, alpha: 0.6) 
        vm.metalness.contents = 0.92; vm.roughness.contents = 0.05; vm.isDoubleSided = true
        helmetGeo.firstMaterial = vm
        let hNode = SCNNode(geometry: helmetGeo)
        hNode.name = "EVAHelmet"
        hNode.position = SCNVector3(0, 1.05, 0)
        let rimGeo = SCNTorus(ringRadius: 0.38, pipeRadius: 0.028)
        let rimMat = SCNMaterial()
        rimMat.diffuse.contents = UIColor(white: 0.65, alpha: 1); rimMat.metalness.contents = 0.95
        rimGeo.firstMaterial = rimMat
        let rimN = SCNNode(geometry: rimGeo)
        rimN.position = SCNVector3(0, 0, 0) 
        hNode.addChildNode(rimN)
        hNode.scale = SCNVector3(0.01, 0.01, 0.01)
        hNode.opacity = 0.0
        astronaut.addChildNode(hNode) 
        let duration: TimeInterval = 0.8
        let scaleAction = SCNAction.scale(to: 1.0, duration: duration)
        scaleAction.timingMode = .easeOut
        let fadeAction = SCNAction.fadeIn(duration: duration * 0.5)
        hNode.runAction(.group([scaleAction, fadeAction]))
        if let rackSuit = scene.rootNode.childNode(withName: "SpaceSuit_0", recursively: true) {
            rackSuit.isHidden = true
        }
    }
    func removeSpaceSuit() {
        astronaut.childNode(withName: "EVAHelmet", recursively: false)?.removeFromParentNode()
        if let rackSuit = scene.rootNode.childNode(withName: "SpaceSuit_0", recursively: true) {
            rackSuit.isHidden = false
        }
    }
    func blinkWarningLights(on: Bool) {
        for i in 0..<3 {
            guard let light = scene.rootNode.childNode(withName: "AirlockWarningLight_\(i)", recursively: true) else { continue }
            if on {
                light.opacity = 1.0
                light.runAction(.repeatForever(.sequence([
                    .fadeOut(duration: 0.4),
                    .fadeIn(duration: 0.4)
                ])), forKey: "warnBlink")
            } else {
                light.removeAction(forKey: "warnBlink")
                light.opacity = 0.2  
            }
        }
    }
    func startEVATimer() {
        evaO2Seconds = 480
        evaTimerTask?.cancel()
        scheduleEVATick()
    }
    private func scheduleEVATick() {
        guard spaceWalkActive, evaO2Seconds > 0 else {
            hud.showEVAStatus(o2Seconds: 0)
            return
        }
        hud.showEVAStatus(o2Seconds: evaO2Seconds)
        let task = DispatchWorkItem { [weak self] in
            guard let self = self, self.spaceWalkActive else { return }
            self.evaO2Seconds -= 1
            self.scheduleEVATick()
        }
        evaTimerTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: task)
    }
    func stopEVATimer() {
        evaTimerTask?.cancel()
        evaTimerTask = nil
        hud.hideEVAStatus()
    }
    func endSpaceWalk() {
        spaceWalkActive = false
        suitedUp = false
        depressurizationStep = 0
        hud.hideManeuverButtons()
        astronaut.stopFloatAnimation()
        stopEVATimer()
        animateHatch1(open: false)
        animateHatch2(open: false)
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(10.0, 0.9, -16.0)
        astronaut.facingAngle = 0
        removeSpaceSuit()
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        astronaut.physicsBody?.damping = 0.3
        astronaut.physicsBody?.angularDamping = 1.0
        if let scaffold = scene.rootNode.childNode(withName: "ExteriorScaffold", recursively: true) {
            scaffold.isHidden = true
        }
        blinkWarningLights(on: false)
        tetherNode?.removeFromParentNode()
        tetherNode = nil
        cableAttached = false
        hatch1Open = false
        animateHatch1(open: false)
        hatch2Open = false
        animateHatch2(open: false)
        updateAirlockButton()
    }
    func sitInChair() {
        guard !isSitting else { return }
        isSitting = true
        joystick?.hide()
        savedAstronautPos = astronaut.presentation.worldPosition
        savedFacingAngle = astronaut.facingAngle
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(-6.50, 0.6, -13.5)
        astronaut.facingAngle = 0
        astronaut.physicsBody?.type = .kinematic
        astronaut.startSitAnimation()
    }
    func standUpFromChair() {
        guard isSitting else { return }
        isSitting = false
        joystick?.show()
        astronaut.stopSitAnimation()
        astronaut.physicsBody?.type = .dynamic
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(-5.50, 0.9, -13.0)
        astronaut.facingAngle = savedFacingAngle
    }
    func joinCommandCenter() {
        guard !isCommanding else { return }
        isCommanding = true
        joystick?.hide()
        savedAstronautPos = astronaut.presentation.worldPosition
        savedFacingAngle = astronaut.facingAngle
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(7.0, 0.6, 11.9)
        astronaut.facingAngle = Float.pi
        astronaut.physicsBody?.type = .kinematic
        astronaut.startSitAnimation()
        hud.updateDataPanel(texts: [
            "COMMAND CONSOLE ACTIVE",
            "> Link to Ground Control: NOMINAL",
            "> Robotics Subsystems: STOWED",
            "> Flight Path: STABLE",
            "Awaiting input..."
        ])
    }
    func leaveCommandCenter() {
        guard isCommanding else { return }
        isCommanding = false
        joystick?.show()
        astronaut.stopSitAnimation()
        astronaut.physicsBody?.type = .dynamic
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(7.0, 0.9, 10.8)
        astronaut.facingAngle = 0
        hud.updateDataPanel(texts: commandRoomStatusLines())
    }
    func sleepInPod() {
        guard !isSleeping else { return }
        isSleeping = true
        joystick?.hide()
        savedAstronautPos = astronaut.presentation.worldPosition
        savedFacingAngle = astronaut.facingAngle
        astronaut.physicsBody?.velocity = SCNVector3Zero
        astronaut.position = SCNVector3(-2.7, 0.6, -11.3) 
        astronaut.facingAngle = .pi / 2
        astronaut.eulerAngles.x = -.pi / 2 
        astronaut.physicsBody?.type = .kinematic
        if let cctv = scene.rootNode.childNode(withName: "CCTVCamera", recursively: true) {
            scnView?.pointOfView = cctv
        }
        toggleRoomLight(for: "LogTrigger", isOn: false)
    }
    func wakeUpFromPod() {
        guard isSleeping else { return }
        isSleeping = false
        astronaut.eulerAngles.x = 0 
        astronaut.facingAngle = savedFacingAngle
        joystick?.show()
        astronaut.physicsBody?.type = .dynamic
        astronaut.physicsBody?.velocity = SCNVector3Zero
        let safeWakePos = SCNVector3(savedAstronautPos.x - 1.0, 0.9, savedAstronautPos.z)
        astronaut.position = safeWakePos
        if let mainCam = scene.rootNode.childNode(withName: "ThirdPersonCamera", recursively: true) {
             scnView?.pointOfView = mainCam
        } else {
             if let astCam = astronaut.childNode(withName: "ThirdPersonCamera", recursively: true) {
                 scnView?.pointOfView = astCam
             } else if let rootCam = scene.rootNode.childNodes.first(where: { $0.camera != nil && $0.name != "CCTVCamera" }) {
                 scnView?.pointOfView = rootCam
             }
        }
        toggleRoomLight(for: "LogTrigger", isOn: true)
    }
    func startRecording() {
        guard !isRecording else { return }
        isRecording = true
        totalRecordingCount += 1
        startRecordingEffects()
        hud.updateDataPanel(texts: ["REC STARTED", "Logging mission data..."])
    }
    func startRecordingEffects() {
        if let recLight = scene.rootNode.childNode(withName: "RecLight", recursively: true) {
            recLight.opacity = 1.0
            recLight.runAction(.repeatForever(.sequence([
                .fadeOut(duration: 0.5), .fadeIn(duration: 0.5)
            ])), forKey: "blinking")
        }
    }
    func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        if let recLight = scene.rootNode.childNode(withName: "RecLight", recursively: true) {
            recLight.removeAction(forKey: "blinking")
            recLight.opacity = 0.2 
        }
        hud.updateDataPanel(texts: ["REC SAVED", "Mission log stored."])
    }
    private func showRecordingSavedMessage(in scene: SKScene) {
        scene.childNode(withName: "savedMessage")?.removeFromParent()
        scene.childNode(withName: "savedMessageLabel")?.removeFromParent()
        let msgBg = SKShapeNode(rectOf: CGSize(width: 320, height: 60), cornerRadius: 14)
        msgBg.fillColor = UIColor(red: 0, green: 0.5, blue: 0.2, alpha: 0.85)
        msgBg.strokeColor = UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1)
        msgBg.lineWidth = 2
        msgBg.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        msgBg.zPosition = 400
        msgBg.name = "savedMessage"
        scene.addChild(msgBg)
        let msgLabel = SKLabelNode(text: "✅ Recording Saved")
        msgLabel.fontName = "Helvetica-Bold"
        msgLabel.fontSize = 22
        msgLabel.fontColor = .white
        msgLabel.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2 - 8)
        msgLabel.zPosition = 401
        msgLabel.name = "savedMessageLabel"
        scene.addChild(msgLabel)
        let waitAndRemove = SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        msgBg.run(waitAndRemove)
        msgLabel.run(waitAndRemove)
    }
    func update() {
        if isSleeping,
           let cctv = scene.rootNode.childNode(withName: "CCTVCamera", recursively: true),
           let joystick = joystick {
            let delta = joystick.getAndResetLookDelta()
            let sensitivity: Float = 0.003
            cctv.eulerAngles.y -= Float(delta.x) * sensitivity
            cctv.eulerAngles.x -= Float(delta.y) * sensitivity
            cctv.eulerAngles.x = max(-1.2, min(0.2, cctv.eulerAngles.x))
            hud.updateMinimap(astronautPosition: astronaut.presentation.worldPosition)
            hud.showSitButton(text: "⏰ Wake Up") { [weak self] in self?.wakeUpFromPod() }
            return
        }
        let pos = astronaut.presentation.worldPosition
        checkRoomBoundaries(position: pos)
        hud.updateMinimap(astronautPosition: pos)
        if currentRoom == "LogTrigger" {
            let deskWorld = SCNVector3(-6.50, 1, -13.5)
            let chairWorld = SCNVector3(-6.50, 1, -13.5)
            let dxDesk = pos.x - deskWorld.x
            let dzDesk = pos.z - deskWorld.z
            let deskDist = sqrt(dxDesk * dxDesk + dzDesk * dzDesk)
            let dxChair = pos.x - chairWorld.x
            let dzChair = pos.z - chairWorld.z
            let chairDist = sqrt(dxChair * dxChair + dzChair * dzChair)
            if deskDist < 3.0 || isRecording {
                let text = isRecording ? "⏹ Stop Recording" : "🔴 Start Recording"
                hud.showRecordButton(text: text) { [weak self] in
                    guard let self = self else { return }
                    if self.isRecording { self.stopRecording() }
                    else { self.startRecording() }
                }
            } else {
                hud.hideRecordButton()
            }
            var showSit = false
            var sitText = ""
            var sitAction: (() -> Void)? = nil
            let podWorld = SCNVector3(-2.6, 0.5, -11.5) 
            let dxPod = pos.x - podWorld.x
            let dzPod = pos.z - podWorld.z
            let podDist = sqrt(dxPod * dxPod + dzPod * dzPod)
            if isSitting {
                showSit = true
                sitText = "🧍‍♂️ Stand Up"
                sitAction = { [weak self] in self?.standUpFromChair() }
            } else if isSleeping {
                showSit = true
                sitText = "⏰ Wake Up"
                sitAction = { [weak self] in self?.wakeUpFromPod() }
            } else {
                let chairInRange = chairDist < 3.0
                let podInRange = podDist < 3.0
                if chairInRange && (!podInRange || chairDist <= podDist) {
                    showSit = true
                    sitText = "🪑 Sit Down"
                    sitAction = { [weak self] in self?.sitInChair() }
                } else if podInRange && (!chairInRange || podDist < chairDist) {
                    showSit = true
                    sitText = "🛌 Sleep"
                    sitAction = { [weak self] in self?.sleepInPod() }
                }
            }
            if showSit, let action = sitAction {
                hud.showSitButton(text: sitText, action: action)
            } else {
                hud.hideSitButton()
            }
        } else if currentRoom == "CommandControlTrigger" {
            let chairWorld = SCNVector3(7.0, 0.6, 11.8) 
            let dxChair = pos.x - chairWorld.x
            let dzChair = pos.z - chairWorld.z
            let chairDist = sqrt(dxChair * dxChair + dzChair * dzChair)
            var showSit = false
            var sitText = ""
            var sitAction: (() -> Void)? = nil
            if isCommanding {
                showSit = true
                sitText = "✅ Commands Done"
                sitAction = { [weak self] in self?.leaveCommandCenter() }
            } else {
                if chairDist < 3.0 {
                    showSit = true
                    sitText = "🪑 Join Command"
                    sitAction = { [weak self] in self?.joinCommandCenter() }
                }
            }
            if showSit, let action = sitAction {
                hud.showSitButton(text: sitText, action: action)
            } else {
                hud.hideSitButton()
            }
            if !isCommanding {
                commandPanelAge += 0.016  
                if commandPanelAge >= commandPanelRefreshInterval {
                    commandPanelAge = 0
                    hud.setDataPanelInstant(texts: commandRoomStatusLines())
                }
            } else {
                hud.setDataPanelInstant(texts: [
                    "COMMAND CONSOLE ACTIVE",
                    "> Link to Ground Control: NOMINAL",
                    "> Robotics Subsystems: STOWED",
                    "> Flight Path: STABLE",
                    "Awaiting input..."
                ])
            }
        } else if currentRoom != "LogTrigger" {
            let interactiveRooms = [
                "WindowRoomTrigger", "ScienceLabTrigger", "TechTrigger",
                "SuitUpTrigger", "Hatch1Trigger", "ChamberTrigger", "Hatch2Trigger"
            ]
            if !interactiveRooms.contains(currentRoom) {
                hud.hideButton()
            }
            hud.hideRecordButton()
            hud.hideSitButton()
        }
        if zeroGEnabled && spaceWalkActive != true {
            let vel = astronaut.physicsBody?.velocity ?? SCNVector3Zero
            let maxFloatY: Float = 2.1  
            let currentY = astronaut.presentation.worldPosition.y
            if currentY >= maxFloatY && vel.y > 0 {
                astronaut.physicsBody?.velocity = SCNVector3(vel.x, 0.0, vel.z)
            } else if vel.y > 5.0 {
                astronaut.physicsBody?.velocity = SCNVector3(vel.x, 5.0, vel.z)
            }
        }
        if spaceWalkActive {
            self.scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
            if let pb = astronaut.physicsBody {
                pb.damping = 0.05
                pb.angularDamping = 0.95
            }
            if astronaut.childNode(withName: "float", recursively: true) != nil {
            }
        }
        if spaceWalkActive {
            updateTether()
        }
    }

    private func updateTether() {
        let astroPos = astronaut.presentation.worldPosition
        var attachPos = SCNVector3(astroPos.x, astroPos.y + 1.2, astroPos.z)
        if let plss = astronaut.childNode(withName: "PLSS", recursively: true) {
            attachPos = plss.presentation.worldPosition
        }
        let anchor = tetherAnchor
        let dx = attachPos.x - anchor.x
        let dy = attachPos.y - anchor.y
        let dz = attachPos.z - anchor.z
        let distance = sqrt(dx*dx + dy*dy + dz*dz)
        if distance > tetherMaxLength {
            let overDir = SCNVector3(dx/distance, dy/distance, dz/distance)
            let clampedPos = SCNVector3(
                anchor.x + overDir.x * tetherMaxLength,
                anchor.y + overDir.y * tetherMaxLength - 1.2,
                anchor.z + overDir.z * tetherMaxLength
            )
            astronaut.position = clampedPos
            if let physics = astronaut.physicsBody {
                let v = physics.velocity
                let dotProd = v.x*overDir.x + v.y*overDir.y + v.z*overDir.z
                if dotProd > 0 { 
                    physics.velocity = SCNVector3(
                        v.x - dotProd * overDir.x,
                        v.y - dotProd * overDir.y,
                        v.z - dotProd * overDir.z
                    )
                }
            }
        }
        let lineLength = min(distance, tetherMaxLength)
        if tetherNode == nil {
            let cyl = SCNCylinder(radius: 0.025, height: CGFloat(lineLength))
            let m = SCNMaterial()
            m.diffuse.contents = UIColor.yellow
            m.emission.contents = UIColor(red: 0.5, green: 0.5, blue: 0, alpha: 1) 
            cyl.firstMaterial = m
            let node = SCNNode(geometry: cyl)
            scene.rootNode.addChildNode(node)
            tetherNode = node
        }
        guard let node = tetherNode, let cyl = node.geometry as? SCNCylinder else { return }
        cyl.height = CGFloat(lineLength)
        node.position = SCNVector3(
            (anchor.x + attachPos.x) / 2.0,
            (anchor.y + attachPos.y) / 2.0,
            (anchor.z + attachPos.z) / 2.0
        )
        node.look(at: attachPos, up: scene.rootNode.worldUp, localFront: SCNNode.localUp)
    }
}
