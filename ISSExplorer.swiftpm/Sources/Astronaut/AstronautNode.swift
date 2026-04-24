import SceneKit
import UIKit


class AstronautNode: SCNNode {
    
    private var bodyNode: SCNNode!
    private var isWalking = false
    private var isFloating = false
    
    private let suitMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(white: 0.95, alpha: 1)
        m.roughness.contents = 0.8; m.metalness.contents = 0.05
        return m
    }()
    
    private let visorMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(red: 0.85, green: 0.65, blue: 0.1, alpha: 0.75)
        m.metalness.contents = 0.95; m.roughness.contents = 0.05
        return m
    }()
    
    private let gloveMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(white: 0.85, alpha: 1)
        m.roughness.contents = 0.7
        return m
    }()
    
    private let bootMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(white: 0.7, alpha: 1)
        m.roughness.contents = 0.8
        return m
    }()
    
    private let accentMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.45, alpha: 1)
        m.metalness.contents = 0.6; m.roughness.contents = 0.4
        return m
    }()
    
    private let backpackMat: SCNMaterial = {
        let m = SCNMaterial()
        m.diffuse.contents = UIColor(white: 0.88, alpha: 1)
        m.metalness.contents = 0.3; m.roughness.contents = 0.5
        return m
    }()
    
    override init() {
        super.init()
        self.name = "Astronaut"
        buildBody()
        setupPhysics()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    var facingAngle: Float {
        get { Float(bodyNode.eulerAngles.y) }
        set { bodyNode.eulerAngles.y = Float(newValue) }
    }
    
    private func buildBody() {
        bodyNode = SCNNode(); bodyNode.name = "AstronautBody"
        
        let torso = SCNCapsule(capRadius: 0.28, height: 0.7)
        torso.firstMaterial = suitMat
        let torsoN = SCNNode(geometry: torso); torsoN.position.y = 0.55
        bodyNode.addChildNode(torsoN)
        let stripe = SCNCylinder(radius: 0.282, height: 0.02)
        stripe.firstMaterial = accentMat
        let sn = SCNNode(geometry: stripe); sn.position.y = 0.55
        bodyNode.addChildNode(sn)
        let helmet = SCNSphere(radius: 0.22)
        helmet.firstMaterial = suitMat
        let helmetN = SCNNode(geometry: helmet); helmetN.position.y = 1.05
        bodyNode.addChildNode(helmetN)
        
        let visor = SCNSphere(radius: 0.19)
        let visorFaceMat = SCNMaterial()
        visorFaceMat.diffuse.contents = UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.3)
        visorFaceMat.transparency = 0.4
        visorFaceMat.lightingModel = .constant
        visor.firstMaterial = visorFaceMat
        let visorN = SCNNode(geometry: visor)
        visorN.position = SCNVector3(0, 1.07, -0.08)
        visorN.scale = SCNVector3(1, 0.9, 0.5)
        bodyNode.addChildNode(visorN)
        
        let eyeMat = SCNMaterial()
        eyeMat.diffuse.contents = UIColor.black
        eyeMat.lightingModel = .constant
        let leftEye = SCNSphere(radius: 0.035)
        leftEye.firstMaterial = eyeMat
        let leftEyeN = SCNNode(geometry: leftEye)
        leftEyeN.position = SCNVector3(-0.07, 1.1, -0.2)
        bodyNode.addChildNode(leftEyeN)
        
        let rightEye = SCNSphere(radius: 0.035)
        rightEye.firstMaterial = eyeMat
        let rightEyeN = SCNNode(geometry: rightEye)
        rightEyeN.position = SCNVector3(0.07, 1.1, -0.2)
        bodyNode.addChildNode(rightEyeN)
        
        let smile = SCNTorus(ringRadius: 0.07, pipeRadius: 0.012)
        let smileMat = SCNMaterial()
        smileMat.diffuse.contents = UIColor.black
        smileMat.lightingModel = .constant
        smile.firstMaterial = smileMat
        let smileN = SCNNode(geometry: smile)
        smileN.position = SCNVector3(0, 1.02, -0.18)
        smileN.eulerAngles.x = .pi / 2
        smileN.scale = SCNVector3(1, 1, 0.5)
        bodyNode.addChildNode(smileN)
        
        let rim = SCNTorus(ringRadius: 0.21, pipeRadius: 0.012)
        rim.firstMaterial = accentMat
        let rimN = SCNNode(geometry: rim); rimN.position.y = 0.95
        bodyNode.addChildNode(rimN)
        let lower = SCNCapsule(capRadius: 0.22, height: 0.4)
        lower.firstMaterial = suitMat
        let lowerN = SCNNode(geometry: lower); lowerN.position.y = 0.15
        bodyNode.addChildNode(lowerN)
        
        for xOff: Float in [-0.12, 0.12] {
            let uLeg = SCNCapsule(capRadius: 0.09, height: 0.35)
            uLeg.firstMaterial = suitMat
            let ulN = SCNNode(geometry: uLeg); ulN.position = SCNVector3(xOff, -0.15, 0)
            ulN.name = xOff < 0 ? "leftLeg" : "rightLeg"
            bodyNode.addChildNode(ulN)
            let boot = SCNBox(width: 0.12, height: 0.08, length: 0.2, chamferRadius: 0.03)
            boot.firstMaterial = bootMat
            let bn = SCNNode(geometry: boot)
            bn.position = SCNVector3(0, -0.23, -0.03)
            ulN.addChildNode(bn)
        }
        
        for xOff: Float in [-0.38, 0.38] {
            let arm = SCNCapsule(capRadius: 0.07, height: 0.45)
            arm.firstMaterial = suitMat
            let an = SCNNode(geometry: arm); an.position = SCNVector3(xOff, 0.55, 0)
            an.eulerAngles.z = xOff < 0 ? 0.15 : -0.15
            an.name = xOff < 0 ? "leftArm" : "rightArm"
            bodyNode.addChildNode(an)
            
            let glove = SCNSphere(radius: 0.055)
            glove.firstMaterial = gloveMat
            let gn = SCNNode(geometry: glove)
            gn.position = SCNVector3(0, -0.27, 0)
            an.addChildNode(gn)
        }
        let pack = SCNBox(width: 0.4, height: 0.55, length: 0.2, chamferRadius: 0.04)
        pack.firstMaterial = backpackMat
        let packN = SCNNode(geometry: pack)
        packN.name = "PLSS"
        packN.position = SCNVector3(0, 0.6, 0.22)
        bodyNode.addChildNode(packN)
        
        for y: Float in [0.72, 0.82] {
            let tube = SCNCylinder(radius: 0.015, height: 0.35)
            let tm = SCNMaterial(); tm.diffuse.contents = UIColor.darkGray
            tube.firstMaterial = tm
            let tn = SCNNode(geometry: tube); tn.eulerAngles.z = .pi/2
            tn.position = SCNVector3(0, y, 0.28)
            bodyNode.addChildNode(tn)
        }
        addChildNode(bodyNode)
    }
    
    private func setupPhysics() {
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(
            geometry: SCNCapsule(capRadius: 0.3, height: 1.6), options: nil))
        
        body.categoryBitMask = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.trigger
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.npc
        body.mass = 70
        body.friction = 0.0
        body.restitution = 0.0
        body.damping = 0.3
        body.angularDamping = 1.0
        body.angularVelocityFactor = SCNVector3(0, 0, 0)
        body.isAffectedByGravity = true
        body.continuousCollisionDetectionThreshold = 0.3
        self.physicsBody = body
    }
    func startWalkAnimation() {
        guard !isWalking else { return }; isWalking = true
        
        let leftLeg  = bodyNode.childNode(withName: "leftLeg",  recursively: false)
        let rightLeg = bodyNode.childNode(withName: "rightLeg", recursively: false)
        let leftArm  = bodyNode.childNode(withName: "leftArm",  recursively: false)
        let rightArm = bodyNode.childNode(withName: "rightArm", recursively: false)
        
        let swing: Float = 0.35
        let d = 0.6
        let legAction = SCNAction.repeatForever(.sequence([
            SCNAction.rotateTo(x: CGFloat(swing),  y: 0, z: 0, duration: d),
            SCNAction.rotateTo(x: CGFloat(-swing), y: 0, z: 0, duration: d)
        ]))
        
        func armSwing(phase: Float) -> SCNAction {
            SCNAction.repeatForever(
                SCNAction.customAction(duration: d * 2) { node, elapsed in
                    let t = Float(elapsed) / Float(d * 2)
                    node.eulerAngles.x = phase * swing * 0.5 * sin(t * 2 * .pi)
                }
            )
        }
        leftLeg?.runAction(legAction,              forKey: "walk")
        rightLeg?.runAction(legAction.reversed(),  forKey: "walk")
        leftArm?.runAction(armSwing(phase:  1),    forKey: "walk")
        rightArm?.runAction(armSwing(phase: -1),   forKey: "walk")
        
        bodyNode.runAction(.repeatForever(.sequence([
            .moveBy(x: 0, y: 0.03, z: 0, duration: d),
            .moveBy(x: 0, y: -0.03, z: 0, duration: d)
        ])), forKey: "bob")
    }
    
    func stopWalkAnimation() {
        guard isWalking else { return }; isWalking = false
        
        for name in ["leftLeg","rightLeg","leftArm","rightArm"] {
            bodyNode.childNode(withName: name, recursively: false)?.removeAllActions()
            bodyNode.childNode(withName: name, recursively: false)?.eulerAngles = SCNVector3(0,0,0)
        }
        bodyNode.removeAction(forKey: "bob")
        bodyNode.runAction(SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.2))
    }
    func startFloatAnimation() {
        guard !isFloating else { return }; isFloating = true
        bodyNode.runAction(.repeatForever(.sequence([
            .moveBy(x: 0, y: 0.08, z: 0, duration: 2),
            .moveBy(x: 0, y: -0.08, z: 0, duration: 2)
        ])), forKey: "float")
    }
    
    func stopFloatAnimation() {
        guard isFloating else { return }; isFloating = false
        
        bodyNode.removeAction(forKey: "float")
        bodyNode.runAction(SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.5))
    }
    
    func startSitAnimation() {
        guard let leftLeg = bodyNode.childNode(withName: "leftLeg", recursively: false),
              let rightLeg = bodyNode.childNode(withName: "rightLeg", recursively: false) else { return }
        
        let sitAngle = CGFloat(-Double.pi / 2)
        let sitAction = SCNAction.rotateTo(x: sitAngle, y: 0, z: 0, duration: 0.5)
        leftLeg.runAction(sitAction)
        rightLeg.runAction(sitAction)
        
        let armAngle = CGFloat(Double.pi / 2.3)
        let armAction = SCNAction.rotateTo(x: armAngle, y: 0, z: 0, duration: 0.5)
        if let leftArm = bodyNode.childNode(withName: "leftArm", recursively: false) {
             leftArm.runAction(armAction)
            
        }
        if let rightArm = bodyNode.childNode(withName: "rightArm", recursively: false) {
             rightArm.runAction(armAction)
        }
    }
    
    func stopSitAnimation() {
        guard let leftLeg = bodyNode.childNode(withName: "leftLeg", recursively: false),
              let rightLeg = bodyNode.childNode(withName: "rightLeg", recursively: false) else { return }
        
        let standAction = SCNAction.rotateTo(x: 0, y: 0, z: 0, duration: 0.5)
        leftLeg.runAction(standAction)
        rightLeg.runAction(standAction)
        
        if let leftArm = bodyNode.childNode(withName: "leftArm", recursively: false) {
             leftArm.runAction(standAction)
        }
        if let rightArm = bodyNode.childNode(withName: "rightArm", recursively: false) {
             rightArm.runAction(standAction)
        }
    }
}
