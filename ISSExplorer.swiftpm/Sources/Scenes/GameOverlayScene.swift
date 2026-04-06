import SpriteKit
import UIKit


class GameOverlayScene: SKScene {
    var joystick: JoystickOverlay?
    var hud: HUDOverlay?
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return }
        if let touch = touches.first {
            let location = touch.location(in: self)
            if hud?.isMissionsExplorerVisible == true {
                joystick?.resetAllInput()
                hud?.handleMissionsTouchBegan(at: location)
                return 
            }
        }
        joystick?.handleTouchBegan(touches, in: view)
        if let touch = touches.first {
            let location = touch.location(in: self)
            hud?.handleTouchBegan(at: location)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return }
        if let touch = touches.first {
            let loc = touch.location(in: self)
            let prev = touch.previousLocation(in: self)
            let delta = CGPoint(x: loc.x - prev.x, y: loc.y - prev.y)
            if hud?.isMissionsExplorerVisible == true {
                joystick?.resetAllInput()
                hud?.handleMissionsTouchMoved(at: loc, delta: delta)
                return 
            }
        }
        joystick?.handleTouchMoved(touches, in: view)
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return }
        if hud?.isMissionsExplorerVisible == true {
            hud?.handleMissionsTouchEnded()
            return
        }
        joystick?.handleTouchEnded(touches, in: view)
        if let touch = touches.first {
            let location = touch.location(in: self)
            hud?.handleTouchEnded(at: location)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return }
        if hud?.isMissionsExplorerVisible == true {
            joystick?.resetAllInput()
            hud?.handleMissionsTouchEnded()
            return 
        }
        joystick?.handleTouchEnded(touches, in: view)
        if let touch = touches.first {
            let location = touch.location(in: self)
            hud?.handleTouchEnded(at: location)
        }
    }
}
