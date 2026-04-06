import SpriteKit
import UIKit


class JoystickOverlay {
    
    var moveDirection: CGPoint = .zero
    var lookDelta: CGPoint = .zero
    weak var hud: HUDOverlay?
    
    private let sceneSize: CGSize
    private var moveBase: SKShapeNode!
    private var moveStick: SKShapeNode!
    private var activeMoveTouch: UITouch?
    private var activeLookTouch: UITouch?
    private var previousLookLocation: CGPoint = .zero
    private let baseRadius: CGFloat = 80
    private let stickRadius: CGFloat = 40
    private let margin: CGFloat = 100
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
    }
    
    func addToScene(_ scene: SKScene) {
        
        let movePos = CGPoint(x: margin + 30, y: margin + 20)
        
        moveBase = createBase(position: movePos)
        moveStick = createStick(position: movePos)
        
        scene.addChild(moveBase)
        scene.addChild(moveStick)
    }
    private func createBase(position: CGPoint) -> SKShapeNode {
        
        let base = SKShapeNode(circleOfRadius: baseRadius)
        
        base.fillColor = UIColor.white.withAlphaComponent(0.1)
        base.strokeColor = UIColor.white.withAlphaComponent(0.3)
        base.lineWidth = 2
        base.position = position
        base.zPosition = 100
        
        return base
    }
    private func createStick(position: CGPoint) -> SKShapeNode {
        
        let stick = SKShapeNode(circleOfRadius: stickRadius)
        
        stick.fillColor = UIColor.white.withAlphaComponent(0.5)
        stick.strokeColor = .white
        stick.lineWidth = 2
        stick.position = position
        stick.zPosition = 101
        
        return stick
    }
    
    func handleTouchBegan(_ touches: Set<UITouch>, in view: SKView) {
        
        for touch in touches {
            
            let location = touch.location(in: moveBase.parent!)
            let dx = location.x - moveBase.position.x
            let dy = location.y - moveBase.position.y
            let distFromMoveCenter = sqrt(dx*dx + dy*dy)
            let moveHitRadius = baseRadius * 2.0
            
            if !moveBase.isHidden && distFromMoveCenter < moveHitRadius && activeMoveTouch == nil {
                activeMoveTouch = touch
                updateStick(base: moveBase, stick: moveStick, location: location)
            }
            else if activeLookTouch == nil {
               activeLookTouch = touch
               previousLookLocation = location
            }
        }
    }
    func handleTouchMoved(_ touches: Set<UITouch>, in view: SKView) {
        
        for touch in touches {
            
            let location = touch.location(in: moveBase.parent!)
            if !moveBase.isHidden && touch == activeMoveTouch {
                updateStick(base: moveBase, stick: moveStick, location: location)
            } else if touch == activeLookTouch {
                let dx = location.x - previousLookLocation.x
                let dy = location.y - previousLookLocation.y
                lookDelta.x += dx
                lookDelta.y += dy
                previousLookLocation = location
            }
        }
    }
    func handleTouchEnded(_ touches: Set<UITouch>, in view: SKView) {
        for touch in touches {
            if touch == activeMoveTouch {
                activeMoveTouch = nil
                if !moveBase.isHidden {
                    resetStick(base: moveBase, stick: moveStick)
                } else {
                    moveDirection = .zero
                }
            } else if touch == activeLookTouch {
                activeLookTouch = nil
                lookDelta = .zero
            }
        }
    }
    private func updateStick(base: SKShapeNode, stick: SKShapeNode, location: CGPoint) {
        let vector = CGPoint(x: location.x - base.position.x, y: location.y - base.position.y)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y)
        let maxDist = baseRadius
        let clampedDist = min(distance, maxDist)
        let angle = atan2(vector.y, vector.x)
        let x = cos(angle) * clampedDist
        let y = sin(angle) * clampedDist
        
        stick.position = CGPoint(x: base.position.x + x, y: base.position.y + y)
        let normalizedX = x / maxDist
        let normalizedY = y / maxDist
        moveDirection = CGPoint(x: normalizedX, y: normalizedY)
    }
    private func resetStick(base: SKShapeNode, stick: SKShapeNode) {
        
        let resetAction = SKAction.move(to: base.position, duration: 0.1)
        resetAction.timingMode = .easeOut
        stick.run(resetAction)
        moveDirection = .zero
    }
    func resetAllInput() {
        
        activeMoveTouch = nil
        activeLookTouch = nil
        lookDelta = .zero
        if !moveBase.isHidden {
            resetStick(base: moveBase, stick: moveStick)
        } else {
            moveDirection = .zero
        }
    }
    func getAndResetLookDelta() -> CGPoint {
        let delta = lookDelta
        lookDelta = .zero
        return delta
    }
    func hide() {
        moveBase.isHidden = true
        moveStick.isHidden = true
    }
    func show() {
        moveBase.isHidden = false
        moveStick.isHidden = false
    }
}
