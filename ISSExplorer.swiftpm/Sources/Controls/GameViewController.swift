import SwiftUI
import SceneKit
import SpriteKit


struct GameSceneView: UIViewRepresentable {
    func makeCoordinator() -> GameCoordinator {
        GameCoordinator()
    }
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.antialiasingMode = .multisampling4X
        scnView.isPlaying = true
        scnView.delegate = context.coordinator
        scnView.backgroundColor = .black
        scnView.allowsCameraControl = false
        scnView.isMultipleTouchEnabled = true
        
        let coordinator = context.coordinator
        let scene = SCNScene()
        
        scnView.scene = scene
        coordinator.scene = scene
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        
        let issBuilder = ISSSceneBuilder()
        let issNode = issBuilder.buildStation()
        scene.rootNode.addChildNode(issNode)
        
        let astronaut = AstronautNode()
        astronaut.position = SCNVector3(-15, 0.9, 0)
        astronaut.facingAngle = -.pi / 2  
        scene.rootNode.addChildNode(astronaut)
        coordinator.astronaut = astronaut
        
        let cameraRig = ThirdPersonCamera(target: astronaut)
        cameraRig.sceneRef = scene
        scene.rootNode.addChildNode(cameraRig.cameraNode)
        scnView.pointOfView = cameraRig.cameraNode
        coordinator.cameraRig = cameraRig
        
        let overlaySize = UIScreen.main.bounds.size
        let overlayScene = GameOverlayScene(size: overlaySize)
        overlayScene.scaleMode = .resizeFill
        overlayScene.backgroundColor = .clear
        
        let joystickOverlay = JoystickOverlay(sceneSize: overlaySize)
        joystickOverlay.addToScene(overlayScene)
        overlayScene.joystick = joystickOverlay
        coordinator.joystickOverlay = joystickOverlay
        
        let hudOverlay = HUDOverlay(sceneSize: overlaySize)
        hudOverlay.addToScene(overlayScene)
        hudOverlay.scnViewRef = scnView   
        overlayScene.hud = hudOverlay
        coordinator.hudOverlay = hudOverlay
        scnView.overlaySKScene = overlayScene
        
        let playerController = PlayerController(
            astronaut: astronaut,
            cameraRig: cameraRig,
            joystick: joystickOverlay
        )
        
        coordinator.playerController = playerController
        let interactionManager = RoomInteractionManager(
            scene: scene,
            astronaut: astronaut,
            hud: hudOverlay,
            scnView: scnView
        )
        
        interactionManager.joystick = joystickOverlay
        joystickOverlay.hud = hudOverlay 
        coordinator.interactionManager = interactionManager
        coordinator.playerController?.roomManager = interactionManager
        
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor(white: 0.4, alpha: 1.0)
        ambientLight.light!.intensity = 200 
        scene.rootNode.addChildNode(ambientLight)
        
        let dirLight = SCNNode()
        dirLight.light = SCNLight()
        dirLight.light!.type = .directional
        dirLight.light!.color = UIColor(white: 0.7, alpha: 1.0)
        dirLight.light!.intensity = 500 
        dirLight.light!.castsShadow = true
        dirLight.eulerAngles = SCNVector3(-Float.pi / 3, Float.pi / 4, 0)
        
        scene.rootNode.addChildNode(dirLight)
        joystickOverlay.hide()
        hudOverlay.showHomeScreen(in: overlayScene)
        scene.rootNode.enumerateChildNodes { (node, stop) in
            if let name = node.name, name.hasSuffix("Light") {
                node.isHidden = true
            }
        }
        
        hudOverlay.onGetStarted = { [weak coordinator, weak scene, weak hudOverlay] in
            hudOverlay?.hideHomeScreen()
            joystickOverlay.show()
            
            coordinator?.playerController?.isGameActive = true
            hudOverlay?.updateRoomLabel(text: "ISS MAIN CORRIDOR")
            
            hudOverlay?.updateDataPanel(texts: [
                "ISS EXPEDITION - YOUR MISSION",
                "Explore 7 modules of the ISS.",
                "Science Lab: run experiments.",
                "Space Walk Room: prepare for EVA.",
                "Command & Control: manage station.",
                "Log Room: save & read mission files.",
                "Window Room: observe the Earth.",
                "Zero-G Room: practice floating.",
                "Mission Explorer: view historical missions."
            ])
            guard let scene = scene, let astronaut = coordinator?.astronaut else { return }
            var corridorLights: [SCNNode] = []
            
            scene.rootNode.enumerateChildNodes { (node, stop) in
                if node.name == "CorridorLight" {
                    corridorLights.append(node)
                }
            }
            let astronautPos = astronaut.presentation.worldPosition
            corridorLights.sort {
                abs($0.worldPosition.x - astronautPos.x) < abs($1.worldPosition.x - astronautPos.x)
            }
            let totalDuration: TimeInterval = 2.5
            
            let delayPerLight = totalDuration / TimeInterval(max(1, corridorLights.count))
            
            for (index, lightNode) in corridorLights.enumerated() {
                let delay = delayPerLight * TimeInterval(index)
                let waitAction = SCNAction.wait(duration: delay)
                let showAction = SCNAction.run { node in
                    node.isHidden = false
                }
                lightNode.runAction(SCNAction.sequence([waitAction, showAction]))
            }
        }
        coordinator.scnViewRef = scnView
        return scnView
    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let overlay = uiView.overlaySKScene, overlay.size != uiView.bounds.size {
            overlay.size = uiView.bounds.size
        }
    }
}
class GameCoordinator: NSObject, SCNSceneRendererDelegate {
    
    var scene: SCNScene?
    var astronaut: AstronautNode?
    var cameraRig: ThirdPersonCamera?
    var playerController: PlayerController?
    var interactionManager: RoomInteractionManager?
    var joystickOverlay: JoystickOverlay?
    var hudOverlay: HUDOverlay?
    
    weak var scnViewRef: SCNView?
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        playerController?.update(deltaTime: time)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        cameraRig?.update(time: time)
        interactionManager?.update()
    }
}
