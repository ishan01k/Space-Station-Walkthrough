import SceneKit


class PlayerController {
    
    let astronaut: AstronautNode
    let cameraRig: ThirdPersonCamera
    let joystick: JoystickOverlay
    
    weak var roomManager: RoomInteractionManager?
    
    var moveSpeed: Float = 4
    var rotationSpeed: Float = 2.5
    var lookSpeed: Float = 3.0
    var touchLookSensitivity: CGFloat = 0.003
    var isGameActive: Bool = false
    
    private var lastTime: TimeInterval = 0
    init(astronaut: AstronautNode, cameraRig: ThirdPersonCamera, joystick: JoystickOverlay) {
        self.astronaut = astronaut
        self.cameraRig = cameraRig
        self.joystick = joystick
    }
    func update(deltaTime time: TimeInterval) {
        let dt = Float(lastTime == 0 ? 1.0/60.0 : time - lastTime)
        lastTime = time
        guard dt < 0.5 else { return }
        guard isGameActive else { return }
        
        let currentY = astronaut.presentation.worldPosition.y
        if roomManager?.spaceWalkActive != true && currentY < -1.5 {
            astronaut.physicsBody?.velocity = SCNVector3(0, 0, 0)
            var pos = astronaut.presentation.worldPosition
            pos.y = 0.9
            astronaut.position = pos
        }
        let isSitting = roomManager?.isSitting == true
        let moveInput = joystick.moveDirection
        let isSleeping = roomManager?.isSleeping == true
        let lookDelta = isSleeping ? .zero : joystick.getAndResetLookDelta()
        if !isSleeping && lookDelta != .zero {
            cameraRig.lookOffset.x -= lookDelta.x * touchLookSensitivity
            cameraRig.lookOffset.y -= lookDelta.y * touchLookSensitivity
            cameraRig.lookOffset.y = max(-1.0, min(1.0, cameraRig.lookOffset.y))
        }
        let inputMagnitude = Float(sqrt(moveInput.x * moveInput.x + moveInput.y * moveInput.y))
        if !isSitting && inputMagnitude > 0.1 {
            
            let camForward = cameraRig.cameraNode.presentation.convertVector(SCNVector3(0, 0,-1), to: nil)
            let camRight = cameraRig.cameraNode.presentation.convertVector(SCNVector3(1, 0, 0), to: nil)
            let forwardX = camForward.x
            let forwardZ = camForward.z
            let rightX = camRight.x
            let rightZ = camRight.z
            
            let fMag = sqrt(forwardX*forwardX + forwardZ*forwardZ)
            let rMag = sqrt(rightX*rightX + rightZ*rightZ)
            let fnX = fMag > 0 ? forwardX/fMag : 0
            let fnZ = fMag > 0 ? forwardZ/fMag : -1
            let rnX = rMag > 0 ? rightX/rMag : 1
            let rnZ = rMag > 0 ? rightZ/rMag : 0
            
            let moveY = Float(moveInput.y)
            let moveX = Float(moveInput.x)
            let dirX = fnX * moveY + rnX * moveX
            let dirZ = fnZ * moveY + rnZ * moveX
            
            let speed = moveSpeed * min(inputMagnitude, 1.0)
            let targetVelX = dirX * speed
            let targetVelZ = dirZ * speed
            var targetVelY: Float = 0
            var accel: Float = 10.0
            
            if roomManager?.spaceWalkActive == true { accel = 1.5
                if joystick.hud?.isUpPressed == true {
                    targetVelY = speed
                } else if joystick.hud?.isDownPressed == true {
                    targetVelY = -speed
                }
            } else {
                targetVelY = (astronaut.physicsBody?.velocity.y ?? 0)
            }
            
            let currentVelX = astronaut.physicsBody?.velocity.x ?? 0
            let currentVelY = astronaut.physicsBody?.velocity.y ?? 0
            let currentVelZ = astronaut.physicsBody?.velocity.z ?? 0
            let t = min(accel * dt, 1.0)
            
            astronaut.physicsBody?.velocity = SCNVector3(
                currentVelX + (targetVelX - currentVelX) * t,
                currentVelY + (targetVelY - currentVelY) * t,
                currentVelZ + (targetVelZ - currentVelZ) * t
            )
            
            let targetAngle = atan2(-dirX, -dirZ)
            var angleDiff = targetAngle - astronaut.facingAngle
            while angleDiff > Float.pi { angleDiff -= 2 * Float.pi }
            while angleDiff < -Float.pi { angleDiff += 2 * Float.pi }
            astronaut.facingAngle += angleDiff * rotationSpeed * dt
            
            if roomManager?.zeroGEnabled != true {
                astronaut.startWalkAnimation()
            }
        } else {
            
            let spaceWalkActive = roomManager?.spaceWalkActive == true
            
            if spaceWalkActive {
                let isProvidingInput = abs(moveInput.x) > 0.01 || abs(moveInput.y) > 0.01
                let decelFactor: Float = isProvidingInput ? 0.98 : 0.85
                let currentVelX = astronaut.physicsBody?.velocity.x ?? 0
                let currentVelY = astronaut.physicsBody?.velocity.y ?? 0
                let currentVelZ = astronaut.physicsBody?.velocity.z ?? 0
                astronaut.physicsBody?.angularVelocity = SCNVector4Zero
                astronaut.physicsBody?.velocity = SCNVector3(
                    currentVelX * decelFactor,
                    currentVelY * decelFactor,
                    currentVelZ * decelFactor
                )
            } else {
                let decel: Float = 12.0
                let t = min(decel * dt, 1.0)
                let currentVelY = astronaut.physicsBody?.velocity.y ?? 0
                let currentVelX = astronaut.physicsBody?.velocity.x ?? 0
                let currentVelZ = astronaut.physicsBody?.velocity.z ?? 0
                let nextVelY = currentVelY
                astronaut.physicsBody?.velocity = SCNVector3(
                    currentVelX * (1.0 - t),
                    nextVelY,
                    currentVelZ * (1.0 - t)
                )
            }
            astronaut.stopWalkAnimation()
        }
    }
}
