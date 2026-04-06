import SceneKit
import UIKit


class NPCAstronaut: SCNNode {
    
    private let accentColor: UIColor
    private var bodyNode: SCNNode!
    init(accentColor: UIColor) {
        self.accentColor = accentColor
        super.init()
        buildBody()
        setupSeatedPose()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func buildBody() {
        let fakeAstronaut = AstronautNode()
        guard let visualBody = fakeAstronaut.childNode(withName: "AstronautBody", recursively: false) else { return }
        visualBody.name = "NPCBody"
        self.bodyNode = visualBody
        self.addChildNode(visualBody)
    }
    private func setupSeatedPose() {
        
        let leftLeg  = bodyNode.childNode(withName: "leftLeg", recursively: false)
        let rightLeg = bodyNode.childNode(withName: "rightLeg", recursively: false)
        let leftArm  = bodyNode.childNode(withName: "leftArm", recursively: false)
        let rightArm = bodyNode.childNode(withName: "rightArm", recursively: false)
        
        leftLeg?.eulerAngles.x  = Float.pi / 7
        rightLeg?.eulerAngles.x = Float.pi / 7
        
        let leanL = SCNAction.rotateTo(x: 0.6, y: 0, z: 0, duration: 0.4)
        leftArm?.runAction(SCNAction.repeatForever(SCNAction.sequence([
            leanL,
            SCNAction.rotateTo(x: 0.55, y: 0, z: 0, duration: 0.10),
            SCNAction.rotateTo(x: 0.65, y: 0, z: 0, duration: 0.10)
        ])))
        
        let leanR = SCNAction.rotateTo(x: 0.6, y: 0, z: 0, duration: 0.4)
        rightArm?.runAction(SCNAction.repeatForever(SCNAction.sequence([
            leanR,
            SCNAction.rotateTo(x: 0.65, y: 0, z: 0, duration: 0.12),
            SCNAction.rotateTo(x: 0.55, y: 0, z: 0, duration: 0.12)
        ])))
    }
}
