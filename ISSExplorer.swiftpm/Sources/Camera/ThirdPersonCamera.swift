import SceneKit


class ThirdPersonCamera {
    
    let cameraNode: SCNNode
    let camera: SCNCamera
    
    weak var target: SCNNode?
    weak var sceneRef: SCNScene?
    
    var distance: Float = 0.0
    var minDistance: Float = 0.0
    var heightOffset: Float = 1.4
    var sideOffset: Float = -1.0
    var smoothSpeed: Float = 0.15
    var lookOffset: CGPoint = .zero
    
    private let defaultPitch: Float = 0.3
    private let maxPitch: Float = 0.8
    private let minPitch: Float = -0.4
    
    init(target: SCNNode) {
        self.target = target
        camera = SCNCamera()
        camera.zNear = 0.1
        camera.zFar = 500
        camera.fieldOfView = 75
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.name = "ThirdPersonCamera"
        
        let targetPos = target.position
        let initAngle = target.eulerAngles.y
        let rotatedDX = sideOffset * cos(initAngle) + distance * sin(initAngle)
        let rotatedDZ = distance * cos(initAngle) - sideOffset * sin(initAngle)
        
        cameraNode.position = SCNVector3(
            targetPos.x + rotatedDX,
            targetPos.y + heightOffset,
            targetPos.z + rotatedDZ
        )
        cameraNode.look(at: targetPos)
    }
    func update() {
        
        guard let target = target else { return }
        
        let targetWorldPos = target.presentation.worldPosition
        let targetEulerY = target.presentation.eulerAngles.y
        let angle = targetEulerY + Float(lookOffset.x)
        let rotatedDX = sideOffset * cos(angle) + distance * sin(angle)
        let rotatedDZ = distance * cos(angle) - sideOffset * sin(angle)
        let desiredX = targetWorldPos.x + rotatedDX
        let desiredZ = targetWorldPos.z + rotatedDZ
        let desiredY = targetWorldPos.y + heightOffset
        var desiredPos = SCNVector3(desiredX, desiredY, desiredZ)
        
        if let scene = sceneRef {
            let rayStart = SCNVector3(targetWorldPos.x, targetWorldPos.y + 1.0, targetWorldPos.z)
            let opts: [SCNPhysicsWorld.TestOption: Any] = [
                SCNPhysicsWorld.TestOption.collisionBitMask: PhysicsCategory.wall,
                SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.closest.rawValue
            ]
            let results = scene.physicsWorld.rayTestWithSegment(
                from: rayStart, to: desiredPos, options: opts
            )
            if let hit = results.first {
                
                let hitPos = hit.worldCoordinates
                let dx = hitPos.x - rayStart.x
                let dy = hitPos.y - rayStart.y
                let dz = hitPos.z - rayStart.z
                let hitDist = sqrt(dx * dx + dy * dy + dz * dz)
                let pullBack: Float = 0.3
                let safeDist = max(minDistance, hitDist - pullBack)
                let vx = desiredPos.x - rayStart.x
                let vy = desiredPos.y - rayStart.y
                let vz = desiredPos.z - rayStart.z
                let len = sqrt(vx*vx + vy*vy + vz*vz)
                
                if len > 0.01 {
                    let ratio = safeDist / len
                    desiredPos = SCNVector3(
                        rayStart.x + vx * ratio,
                        rayStart.y + vy * ratio,
                        rayStart.z + vz * ratio
                    )
                }
            }
        }
        let posSmooth: Float = 18.0
        
        let pt = posSmooth * (1.0 / 60.0)
        cameraNode.position = SCNVector3(
            cameraNode.position.x + (desiredPos.x - cameraNode.position.x) * pt,
            cameraNode.position.y + (desiredPos.y - cameraNode.position.y) * pt,
            cameraNode.position.z + (desiredPos.z - cameraNode.position.z) * pt
        )
        let finalYaw = angle - .pi / 2
        let finalPitch = defaultPitch + Float(lookOffset.y)
        let rotSmooth: Float = 8.0
        let clampedPitch = -max(minPitch, min(maxPitch, finalPitch))
        
        cameraNode.eulerAngles.y += (finalYaw - cameraNode.eulerAngles.y) * rotSmooth * (1.0 / 60.0)
        cameraNode.eulerAngles.x += (clampedPitch - cameraNode.eulerAngles.x) * rotSmooth * (1.0 / 60.0)
        cameraNode.eulerAngles.z = 0
    }
}
