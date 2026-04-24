import SceneKit


class ISSSceneBuilder {
    
    let wallMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.9, alpha: 1)
        m.roughness.contents = 0.8; m.metalness.contents = 0.1; return m
    }()
    
    let fabricMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.95, alpha: 1)
        m.roughness.contents = 0.9; m.normal.contents = UIColor(white: 0.5, alpha: 1)
        return m
    }()
    
    let panelMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.88, alpha: 1)
        m.metalness.contents = 0.3; m.roughness.contents = 0.6; return m
    }()
    
    let floorMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.82, alpha: 1)
        m.metalness.contents = 0.2; m.roughness.contents = 0.7; return m
    }()
    let blueMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(red: 0.05, green: 0.2, blue: 0.6, alpha: 1)
        m.metalness.contents = 0.6; m.roughness.contents = 0.4; return m
    }()
    let cableMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.9, alpha: 1)
        m.roughness.contents = 0.6; return m
    }()
    let darkMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.2, alpha: 1)
        m.metalness.contents = 0.7; return m
    }()
    let screenMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(red: 0.02, green: 0.06, blue: 0.15, alpha: 1)
        m.emission.contents = UIColor(red: 0.0, green: 0.1, blue: 0.25, alpha: 1); return m
    }()
    let ceilingPadMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.92, alpha: 1)
        m.roughness.contents = 0.9; return m
    }()
    let trussMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.7, alpha: 1)
        m.metalness.contents = 0.8; m.roughness.contents = 0.6; return m
    }()
    let solarMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(red: 0.05, green: 0.1, blue: 0.25, alpha: 1)
        m.metalness.contents = 0.9; m.roughness.contents = 0.2
        m.emission.contents = UIColor(red: 0.0, green: 0.05, blue: 0.1, alpha: 1)
        return m
    }()
    let radiatorMat: SCNMaterial = {
        let m = SCNMaterial(); m.diffuse.contents = UIColor(white: 0.95, alpha: 1)
        m.emission.contents = UIColor(white: 0.8, alpha: 1); return m
    }()
    func addStaticPhysics(to node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.categoryBitMask = PhysicsCategory.wall
        node.physicsBody?.collisionBitMask = PhysicsCategory.player
    }
    func buildStation() -> SCNNode {
        let root = SCNNode(); root.name = "ISS_Root"
        root.addChildNode(buildCorridor())
        root.addChildNode(buildWindowRoom(at: SCNVector3(-12, 0, -8)))
        root.addChildNode(buildLogRoom(at: SCNVector3(-5, 0, -8)))
        root.addChildNode(buildZeroGRoom(at: SCNVector3(3, 0, -8)))
        root.addChildNode(buildAirlockRoom(at: SCNVector3(10, 0, -8)))
        root.addChildNode(buildTechRoom(at: SCNVector3(17, 0, -8)))
        root.addChildNode(buildScienceLab(at: SCNVector3(-7, 0, 8)))
        root.addChildNode(buildCommandControl(at: SCNVector3(7, 0, 8)))
        let leftRoomXPositions: [Float] = [-12, -5, 3, 10, 17]
        for x in leftRoomXPositions {
            root.addChildNode(buildConnectingPassage(atX: x, corridorZ: -4, roomZ: -8, width: 3, height: 3.5))
        }
        let rightRoomXPositions: [Float] = [-7, 7]
        for x in rightRoomXPositions {
            root.addChildNode(buildConnectingPassage(atX: x, corridorZ: 4, roomZ: 8, width: 3, height: 3.5))
        }
        addCorridorLighting(to: root)
        root.addChildNode(buildExteriorStructures())
        let npc1 = NPCAstronaut(accentColor: UIColor(red: 0.9, green: 0.45, blue: 0.05, alpha: 1))
        npc1.name = "npc 1"
        npc1.position = SCNVector3(5.2, 0.72, 11.8)
        npc1.eulerAngles.y = Float.pi 
        root.addChildNode(npc1)
        let npc2 = NPCAstronaut(accentColor: UIColor(red: 0.1, green: 0.7, blue: 0.55, alpha: 1))
        npc2.name = "npc 2"
        npc2.position = SCNVector3(-5.6, 0.70, 11.8)
        npc2.eulerAngles.y = 0
        root.addChildNode(npc2)
        return root
    }
    func buildRoomLabel(_ text: String, at pos: SCNVector3, facingZ: Float) -> SCNNode {
        let container = SCNNode()
        container.position = pos
        let textGeo = SCNText(string: text, extrusionDepth: 0.02)
        textGeo.font = UIFont(name: "Helvetica-Bold", size: 0.30) ?? UIFont.boldSystemFont(ofSize: 0.30)
        textGeo.flatness = 0.005
        let textMat = SCNMaterial()
        textMat.diffuse.contents = UIColor(white: 0.18, alpha: 1)
        textMat.lightingModel    = .constant
        textGeo.firstMaterial = textMat
        let textNode = SCNNode(geometry: textGeo)
        let (minB, maxB) = textNode.boundingBox
        let w = maxB.x - minB.x
        let h = maxB.y - minB.y
        textNode.position = SCNVector3(-w / 2, -h / 2, 0)
        container.addChildNode(textNode)
        if facingZ < 0 {
            container.eulerAngles.y = .pi
        }
        return container
    }
    func buildConnectingPassage(atX xPos: Float, corridorZ: Float, roomZ: Float, width: Float, height: CGFloat) -> SCNNode {
        let passage = SCNNode()
        passage.name = "Passage_\(xPos)"
        let passageLen = abs(roomZ - corridorZ)
        let halfW = width / 2.0
        let centerZ = (corridorZ + roomZ) / 2.0
        let floor = SCNBox(width: CGFloat(width), height: 0.15, length: CGFloat(passageLen), chamferRadius: 0)
        floor.firstMaterial = floorMat
        let fn = SCNNode(geometry: floor)
        fn.position = SCNVector3(xPos, 0, centerZ)
        fn.physicsBody = .static(); fn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        passage.addChildNode(fn)
        let ceil = SCNBox(width: CGFloat(width), height: 0.15, length: CGFloat(passageLen), chamferRadius: 0)
        ceil.firstMaterial = ceilingPadMat
        let cn = SCNNode(geometry: ceil)
        cn.position = SCNVector3(xPos, Float(height), centerZ)
        cn.physicsBody = .static(); cn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        passage.addChildNode(cn)
        for side: Float in [-1, 1] {
            let wall = SCNBox(width: 0.15, height: height, length: CGFloat(passageLen), chamferRadius: 0)
            wall.firstMaterial = wallMat
            let wn = SCNNode(geometry: wall)
            wn.position = SCNVector3(xPos + side * halfW, Float(height / 2), centerZ)
            wn.physicsBody = .static(); wn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            passage.addChildNode(wn)
        }
        for side: Float in [-1, 1] {
            let rail = SCNCylinder(radius: 0.016, height: CGFloat(passageLen))
            rail.firstMaterial = blueMat
            let rn = SCNNode(geometry: rail)
            rn.eulerAngles.x = .pi / 2
            rn.position = SCNVector3(xPos + side * (halfW - 0.15), 1.6, centerZ)
            passage.addChildNode(rn)
        }
        let light = SCNLight(); light.type = .omni
        light.color = UIColor(white: 0.8, alpha: 1); light.intensity = 200 
        light.attenuationStartDistance = 1; light.attenuationEndDistance = 8
        let ln = SCNNode(); ln.light = light
        ln.position = SCNVector3(xPos, Float(height) - 0.2, centerZ)
        passage.addChildNode(ln)
        let lineMat = SCNMaterial(); lineMat.diffuse.contents = UIColor(white: 0.65, alpha: 1)
        for z in stride(from: corridorZ, through: roomZ, by: -1.5) {
            let line = SCNBox(width: CGFloat(width - 0.5), height: 0.005, length: 0.02, chamferRadius: 0)
            line.firstMaterial = lineMat
            let ln = SCNNode(geometry: line)
            ln.position = SCNVector3(xPos, 0.08, z)
            passage.addChildNode(ln)
        }
        return passage
    }
    func buildExteriorStructures() -> SCNNode {
        let ext = SCNNode(); ext.name = "Exterior"
        let starM = SCNMaterial(); starM.diffuse.contents = UIColor.white; starM.emission.contents = UIColor.white
        for _ in 0..<300 {
            let star = SCNSphere(radius: CGFloat.random(in: 0.025...0.06))
            star.firstMaterial = starM
            let sn = SCNNode(geometry: star)
            let theta = Float.random(in: 0...(2 * .pi))
            let phi   = Float.random(in: 0...(.pi / 2))
            let r     = Float.random(in: 35...80)
            sn.position = SCNVector3(r * sin(phi) * cos(theta), r * cos(phi), r * sin(phi) * sin(theta))
            ext.addChildNode(sn)
        }
        let earthGeo = SCNSphere(radius: 2000)
        earthGeo.segmentCount = 128
        earthGeo.firstMaterial = makeEarthMaterial()
        let earthN = SCNNode(geometry: earthGeo)
        earthN.name = "GlobalEarth"
        earthN.position = SCNVector3(0, -2000, -800)
        earthN.runAction(.repeatForever(.rotateBy(x: 0, y: 0.05, z: 0, duration: 60)))
        earthN.physicsBody = .static()
        earthN.physicsBody?.categoryBitMask = PhysicsCategory.wall
        ext.addChildNode(earthN)
        let atmoGeo = SCNSphere(radius: 2020)
        let atmoMat = SCNMaterial()
        atmoMat.diffuse.contents = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.08)
        atmoMat.emission.contents = UIColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.15)
        atmoMat.isDoubleSided = true; atmoGeo.firstMaterial = atmoMat
        let atmoN = SCNNode(geometry: atmoGeo)
        atmoN.position = earthN.position
        ext.addChildNode(atmoN)
        
        let moonGeo = SCNSphere(radius: 120)
        moonGeo.segmentCount = 64
        let moonMat = SCNMaterial()
        moonMat.diffuse.contents = UIColor(white: 0.6, alpha: 1.0)
        moonGeo.firstMaterial = moonMat
        let moonN = SCNNode(geometry: moonGeo)
        moonN.name = "Moon"
        moonN.position = SCNVector3(-1500, 800, -3500)
        moonN.physicsBody = .static()
        moonN.physicsBody?.categoryBitMask = PhysicsCategory.wall
        ext.addChildNode(moonN)
        let trussLen: CGFloat = 100
        let trussSection: CGFloat = 1.5
        let truss = SCNBox(width: trussSection, height: trussSection, length: trussLen, chamferRadius: 0.1)
        truss.firstMaterial = trussMat
        let tn = SCNNode(geometry: truss)
        tn.position = SCNVector3(2.5, 12, -4)
        ext.addChildNode(tn)
        for z in stride(from: -45, through: 45, by: 5.0) {
           let rib = SCNBox(width: 2.0, height: 2.0, length: 0.5, chamferRadius: 0)
           rib.firstMaterial = trussMat
           let rn = SCNNode(geometry: rib); rn.position = SCNVector3(2.5, 12, Double(z))
           if z != 0 { ext.addChildNode(rn) }
        }
        let panelW: CGFloat = 8
        let panelH: CGFloat = 30
        let zPositions: [Float] = [-40, -32, 32, 40]
        for z in zPositions {
            let mast = SCNCylinder(radius: 0.3, height: 6)
            mast.firstMaterial = trussMat
            let mn = SCNNode(geometry: mast)
            mn.eulerAngles.z = .pi / 2
            let wing = SCNNode()
            wing.position = SCNVector3(2.5, 12, z)
            let panel = SCNBox(width: panelW, height: 0.2, length: panelH, chamferRadius: 0)
            panel.firstMaterial = solarMat
            let pn = SCNNode(geometry: panel)
            pn.eulerAngles.x = .pi / 4
            pn.physicsBody = .static()
            pn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            wing.addChildNode(pn)
            ext.addChildNode(wing)
        }
        let radPositions: [Float] = [-10, 10]
        for z in radPositions {
             let rad = SCNBox(width: 6, height: 0.1, length: 12, chamferRadius: 0)
             rad.firstMaterial = radiatorMat
             let rn = SCNNode(geometry: rad)
             rn.position = SCNVector3(2.5, 12, z)
             rn.eulerAngles.x = -.pi / 4
             rn.physicsBody = .static()
             rn.physicsBody?.categoryBitMask = PhysicsCategory.wall
             ext.addChildNode(rn)
        }
        return ext
    }
    func buildCorridor() -> SCNNode {
        let c = SCNNode(); c.name = "MainCorridor"
        let L: CGFloat = 40, W: CGFloat = 8, H: CGFloat = 5
        let floor = SCNBox(width: L, height: 0.15, length: W, chamferRadius: 0)
        floor.firstMaterial = floorMat
        let fn = SCNNode(geometry: floor); fn.position.y = 0
        fn.physicsBody = .static(); fn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        c.addChildNode(fn)
        addFloorGrid(to: c, length: L, width: W)
        let ceil = SCNBox(width: L, height: 0.15, length: W, chamferRadius: 0)
        ceil.firstMaterial = ceilingPadMat
        let cn = SCNNode(geometry: ceil); cn.position.y = Float(H)
        cn.physicsBody = .static(); cn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        c.addChildNode(cn)
        addCeilingPads(to: c, length: L, width: W, height: H)
        buildDetailedWall(parent: c, zPos: Float(-W/2), height: H, length: L, hasOpenings: true)
        buildDetailedWallRight(parent: c, zPos: Float(W/2), height: H, length: L)
        for xPos in [Float(-L/2), Float(L/2)] {
            let ew = SCNBox(width: 0.15, height: H, length: W, chamferRadius: 0)
            ew.firstMaterial = wallMat
            let en = SCNNode(geometry: ew); en.position = SCNVector3(xPos, Float(H/2), 0)
            en.physicsBody = .static(); en.physicsBody?.categoryBitMask = PhysicsCategory.wall
            c.addChildNode(en)
            addHatch(to: c, at: SCNVector3(xPos, Float(H/2), 0), axis: .x)
        }
        addHandrails(to: c, length: L, height: H, width: W)
        addCeilingPipes(to: c, length: L, height: H)
        addRoomTrigger(to: c, name: "CorridorTrigger", width: 38, depth: 7, height: 5)
        return c
    }
    func buildDetailedWall(parent: SCNNode, zPos: Float, height: CGFloat, length: CGFloat, hasOpenings: Bool) {
        let openings: [(x: Float, w: Float)] = hasOpenings ? [(-12,3),(-5,3),(3,3),(10,3),(17,3)] : []
        let segments = computeWallSegments(totalLength: Float(length), openings: openings)
        for seg in segments {
            let w = CGFloat(seg.width)
            let wall = SCNBox(width: w, height: height, length: 0.15, chamferRadius: 0)
            wall.firstMaterial = wallMat
            let node = SCNNode(geometry: wall)
            node.position = SCNVector3(seg.centerX, Float(height/2), zPos)
            node.physicsBody = .static(); node.physicsBody?.categoryBitMask = PhysicsCategory.wall
            parent.addChildNode(node)
            let panelCount = max(1, Int(w / 1.8))
            for i in 0..<panelCount {
                let px = seg.centerX - Float(w)/2 + Float(i) * Float(w) / Float(panelCount) + Float(w) / Float(panelCount * 2)
                let yr: Float = zPos < 0 ? 0 : .pi
                addEquipmentRack(to: parent, at: SCNVector3(px, Float(height/2), zPos + (zPos < 0 ? 0.1 : -0.1)), yRotation: yr)
            }
        }
        if hasOpenings {
            let passageH: CGFloat = 3.5
            let headerH = height - passageH
            if headerH > 0 {
                for op in openings {
                    let header = SCNBox(width: CGFloat(op.w), height: headerH, length: 0.15, chamferRadius: 0)
                    header.firstMaterial = wallMat
                    let hn = SCNNode(geometry: header)
                    hn.position = SCNVector3(op.x, Float(passageH + headerH/2), zPos)
                    hn.physicsBody = .static(); hn.physicsBody?.categoryBitMask = PhysicsCategory.wall
                    parent.addChildNode(hn)
                }
            }
        }
    }
    func buildDetailedWallRight(parent: SCNNode, zPos: Float, height: CGFloat, length: CGFloat) {
        let openings: [(x: Float, w: Float)] = [(-7, 3), (7, 3)]
        let segments = computeWallSegments(totalLength: Float(length), openings: openings)
        for seg in segments {
            let w = CGFloat(seg.width)
            let wall = SCNBox(width: w, height: height, length: 0.15, chamferRadius: 0)
            wall.firstMaterial = wallMat
            let node = SCNNode(geometry: wall)
            node.position = SCNVector3(seg.centerX, Float(height/2), zPos)
            node.physicsBody = .static(); node.physicsBody?.categoryBitMask = PhysicsCategory.wall
            parent.addChildNode(node)
            let panelCount = max(1, Int(w / 1.8))
            for i in 0..<panelCount {
                let px = seg.centerX - Float(w)/2 + Float(i) * Float(w) / Float(panelCount) + Float(w) / Float(panelCount * 2)
                let yr2: Float = zPos < 0 ? 0 : .pi
                addEquipmentRack(to: parent, at: SCNVector3(px, Float(height/2), zPos - 0.1), yRotation: yr2)
            }
        }
        let passageH: CGFloat = 3.5
        let headerH = height - passageH
        if headerH > 0 {
            for op in openings {
                let header = SCNBox(width: CGFloat(op.w), height: headerH, length: 0.15, chamferRadius: 0)
                header.firstMaterial = wallMat
                let hn = SCNNode(geometry: header)
                hn.position = SCNVector3(op.x, Float(passageH + headerH/2), zPos)
                hn.physicsBody = .static(); hn.physicsBody?.categoryBitMask = PhysicsCategory.wall
                parent.addChildNode(hn)
            }
        }
    }
    func addEquipmentRack(to parent: SCNNode, at pos: SCNVector3, yRotation: Float = 0) {
        let rack = SCNNode()
        let panel = SCNBox(width: 1.2, height: 2.2, length: 0.08, chamferRadius: 0.01)
        panel.firstMaterial = panelMat
        let pn = SCNNode(geometry: panel)
        addStaticPhysics(to: pn)
        rack.addChildNode(pn)
        let frame = SCNBox(width: 1.25, height: 2.25, length: 0.03, chamferRadius: 0)
        let frameMat = SCNMaterial(); frameMat.diffuse.contents = UIColor(white: 0.6, alpha: 1)
        frameMat.metalness.contents = 0.7; frame.firstMaterial = frameMat
        let frn = SCNNode(geometry: frame); frn.position.z = -0.04; rack.addChildNode(frn)
        let vent = SCNTorus(ringRadius: 0.25, pipeRadius: 0.025)
        vent.firstMaterial = darkMat
        let vn = SCNNode(geometry: vent); vn.position = SCNVector3(0.0, 0.5, 0.05)
        vn.eulerAngles.x = .pi/2; rack.addChildNode(vn)
        let ventCenter = SCNCylinder(radius: 0.2, height: 0.02)
        ventCenter.firstMaterial = darkMat
        let vcn = SCNNode(geometry: ventCenter); vcn.position = vn.position
        vcn.eulerAngles.x = .pi/2; rack.addChildNode(vcn)
        let scr = SCNPlane(width: 0.35, height: 0.25)
        scr.firstMaterial = screenMat
        let sn = SCNNode(geometry: scr); sn.position = SCNVector3(-0.3, -0.3, 0.05)
        rack.addChildNode(sn)
        for i in 0..<3 {
            let btn = SCNCylinder(radius: 0.03, height: 0.03)
            let btnM = SCNMaterial()
            btnM.diffuse.contents = [UIColor.green, UIColor.yellow, UIColor.red][i]
            btnM.emission.contents = btnM.diffuse.contents
            btn.firstMaterial = btnM
            let bn = SCNNode(geometry: btn); bn.eulerAngles.x = .pi/2
            bn.position = SCNVector3(0.1 + Float(i) * 0.12, -0.65, 0.05)
            rack.addChildNode(bn)
        }
        let handle = SCNCapsule(capRadius: 0.015, height: 0.3)
        handle.firstMaterial = darkMat
        let hn = SCNNode(geometry: handle)
        hn.position = SCNVector3(0.5, 0, 0.06); rack.addChildNode(hn)
        rack.position = pos
        rack.eulerAngles.y = yRotation
        parent.addChildNode(rack)
    }
    func addHatch(to parent: SCNNode, at pos: SCNVector3, axis: Axis) {
        let ring = SCNTorus(ringRadius: 1.3, pipeRadius: 0.08)
        ring.firstMaterial = darkMat
        let rn = SCNNode(geometry: ring); rn.position = pos
        if axis == .z { rn.eulerAngles.x = .pi/2 }
        else { rn.eulerAngles.z = .pi/2 }
        parent.addChildNode(rn)
    }
    enum Axis { case x, z }
    func addHandrails(to parent: SCNNode, length: CGFloat, height: CGFloat, width: CGFloat) {
        let zRight = Float(width/2 - 0.2)
        let rightOpenings: [(x: Float, w: Float)] = [(-7, 3), (7, 3)]
        let rightSegments = computeWallSegments(totalLength: Float(length), openings: rightOpenings)
        for seg in rightSegments {
            placeRail(to: parent, x: seg.centerX, length: seg.width, z: zRight)
        }
        let zLeft = Float(-width/2 + 0.2)
        let leftOpenings: [(x: Float, w: Float)] = [(-12,3),(-5,3),(3,3),(10,3),(17,3)]
        let leftSegments = computeWallSegments(totalLength: Float(length), openings: leftOpenings)
        for seg in leftSegments {
            placeRail(to: parent, x: seg.centerX, length: seg.width, z: zLeft)
        }
    }
    func placeRail(to parent: SCNNode, x: Float, length: Float, z: Float) {
        let rail = SCNCylinder(radius: 0.016, height: CGFloat(length))
        rail.firstMaterial = blueMat
        let rn = SCNNode(geometry: rail); rn.eulerAngles.z = .pi/2
        rn.position = SCNVector3(x, 1.6, z)
        parent.addChildNode(rn)
        let clipCount = max(1, Int(length / 1.0))
        for ci in 0..<clipCount {
            let clipX = x - length/2 + Float(ci) * (length / Float(clipCount)) + length / Float(clipCount*2)
            let clip = SCNBox(width: 0.04, height: 0.05, length: 0.04, chamferRadius: 0.01)
            clip.firstMaterial = blueMat
            let clipN = SCNNode(geometry: clip); clipN.position = SCNVector3(clipX, 1.6, z)
            parent.addChildNode(clipN)
        }
    }
    func addFloorGrid(to parent: SCNNode, length: CGFloat, width: CGFloat) {
        let lineMat = SCNMaterial(); lineMat.diffuse.contents = UIColor(white: 0.65, alpha: 1)
        for z in stride(from: Float(-width/2 + 0.8), through: Float(width/2 - 0.8), by: 0.8) {
            let line = SCNBox(width: length, height: 0.005, length: 0.02, chamferRadius: 0)
            line.firstMaterial = lineMat
            let ln = SCNNode(geometry: line); ln.position = SCNVector3(0, 0.08, z)
            parent.addChildNode(ln)
        }
        for x in stride(from: Float(-length/2), through: Float(length/2), by: 1.5) {
            let line = SCNBox(width: 0.02, height: 0.005, length: width - 0.5, chamferRadius: 0)
            line.firstMaterial = lineMat
            let ln = SCNNode(geometry: line); ln.position = SCNVector3(x, 0.08, 0)
            parent.addChildNode(ln)
        }
        for z in [Float(-width/2 + 0.3), Float(width/2 - 0.3)] {
            let rail = SCNBox(width: length, height: 0.03, length: 0.1, chamferRadius: 0.01)
            rail.firstMaterial = blueMat
            let rn = SCNNode(geometry: rail); rn.position = SCNVector3(0, 0.085, z)
            parent.addChildNode(rn)
        }
    }
    func addCeilingPads(to parent: SCNNode, length: CGFloat, width: CGFloat, height: CGFloat) {
        let padMat = SCNMaterial()
        padMat.diffuse.contents = UIColor(white: 0.95, alpha: 1); padMat.roughness.contents = 0.95
        for x in stride(from: Float(-length/2 + 1), through: Float(length/2 - 1), by: 2.0) {
            for z in stride(from: Float(-width/2 + 0.6), through: Float(width/2 - 0.6), by: 1.2) {
                let pad = SCNBox(width: 1.5, height: 0.06, length: 0.9, chamferRadius: 0.02)
                pad.firstMaterial = padMat
                let pn = SCNNode(geometry: pad)
                pn.position = SCNVector3(x, Float(height) - 0.05, z)
                parent.addChildNode(pn)
            }
        }
    }
    func addCeilingPipes(to parent: SCNNode, length: CGFloat, height: CGFloat) {
        let pipeMat = SCNMaterial()
        pipeMat.diffuse.contents = UIColor(white: 0.55, alpha: 1); pipeMat.metalness.contents = 0.7
        for zOff: Float in [-1.0, 1.0] {
            let pipe = SCNCylinder(radius: 0.04, height: length)
            pipe.firstMaterial = pipeMat
            let pn = SCNNode(geometry: pipe); pn.eulerAngles.z = .pi/2
            pn.position = SCNVector3(0, Float(height) - 0.05, zOff)
            parent.addChildNode(pn)
        }
        for zOff: Float in [-0.5, 0.5] {
            let cable = SCNCylinder(radius: 0.02, height: length)
            let cm = SCNMaterial(); cm.diffuse.contents = UIColor.darkGray
            cable.firstMaterial = cm
            let cn = SCNNode(geometry: cable); cn.eulerAngles.z = .pi/2
            cn.position = SCNVector3(0, Float(height) - 0.05, zOff)
            parent.addChildNode(cn)
        }
    }

    func addCorridorLighting(to root: SCNNode) {
        let zOffsets: [Float] = [-1.5, 1.5]
        for x in stride(from: -18, through: 18, by: 8) {
            let xf = Float(x)
            for zf in zOffsets {
                let light = SCNLight(); light.type = .omni
                light.color = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1); light.intensity = 600
                light.attenuationStartDistance = 2; light.attenuationEndDistance = 10
                let ln = SCNNode(); ln.light = light; ln.position = SCNVector3(xf, 4.8, zf)
                ln.name = "CorridorLight"
                root.addChildNode(ln)
                let strip = SCNBox(width: 1.5, height: 0.03, length: 0.15, chamferRadius: 0.01)
                let sm = SCNMaterial(); sm.diffuse.contents = UIColor.white
                sm.emission.contents = UIColor(white: 0.95, alpha: 1); strip.firstMaterial = sm
                let sn = SCNNode(geometry: strip); sn.position = SCNVector3(xf, 4.98, zf)
                root.addChildNode(sn)
            }
        }
    }
    struct WallSegment { let centerX: Float; let width: Float }
    func computeWallSegments(totalLength: Float, openings: [(x: Float, w: Float)]) -> [WallSegment] {
        var segs: [WallSegment] = []; let half = totalLength / 2; var cur = -half
        for op in openings.sorted(by: { $0.x < $1.x }) {
            let s = op.x - op.w / 2, e = op.x + op.w / 2
            if s > cur { let w = s - cur; segs.append(WallSegment(centerX: cur + w/2, width: w)) }
            cur = e
        }
        if cur < half { let w = half - cur; segs.append(WallSegment(centerX: cur + w/2, width: w)) }
        return segs
    }
    func buildWindowRoom(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "WindowRoom"; room.position = pos
        let w: CGFloat = 8, d: CGFloat = 8, h: CGFloat = 6
        let ceil = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); ceil.firstMaterial = ceilingPadMat
        let cn = SCNNode(geometry: ceil); cn.position = SCNVector3(0, Float(h), Float(-d/2))
        cn.physicsBody = .static(); cn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(cn)
        let floor = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); floor.firstMaterial = floorMat
        let fn = SCNNode(geometry: floor); fn.position = SCNVector3(0, 0, Float(-d/2))
        fn.physicsBody = .static(); fn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(fn)
        let walls: [(CGFloat,CGFloat,CGFloat,SCNVector3)] = [
            (0.15, h, d, SCNVector3(Float(-w/2), Float(h/2), Float(-d/2))),
            (0.15, h, d, SCNVector3(Float(w/2), Float(h/2), Float(-d/2))),
        ]
        for (ww, hh, ll, p) in walls {
            let box = SCNBox(width: ww, height: hh, length: ll, chamferRadius: 0); box.firstMaterial = wallMat
            let n = SCNNode(geometry: box); n.position = p
            n.physicsBody = .static(); n.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(n)
        }
        let openingWidth: CGFloat = 3.0; let segmentWidth = (w - openingWidth) / 2.0
        for side: CGFloat in [-1, 1] {
            let fw = SCNBox(width: segmentWidth, height: h, length: 0.15, chamferRadius: 0)
            fw.firstMaterial = wallMat
            let fwn = SCNNode(geometry: fw)
            let xOff = side * (openingWidth / 2.0 + segmentWidth / 2.0)
            fwn.position = SCNVector3(Float(xOff), Float(h / 2), 0)
            fwn.physicsBody = .static(); fwn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            room.addChildNode(fwn)
        }
        let doorH: CGFloat = 3.5
        let headerH = h - doorH
        let fHeader = SCNBox(width: openingWidth, height: headerH, length: 0.15, chamferRadius: 0)
        fHeader.firstMaterial = wallMat
        let fhn = SCNNode(geometry: fHeader)
        fhn.position = SCNVector3(0, Float(doorH + headerH / 2), 0)
        fhn.physicsBody = .static(); fhn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        room.addChildNode(fhn)
        let backWallZ = Float(-d)
        let cupolaCenterY: Float = 3.5
        let holeRadius: CGFloat = 2.45
        
        let wallPath = UIBezierPath(rect: CGRect(x: -w/2, y: 0, width: w, height: h))
        let holePath = UIBezierPath(arcCenter: CGPoint(x: 0, y: CGFloat(cupolaCenterY)), radius: holeRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        wallPath.append(holePath)
        
        let backWall = SCNShape(path: wallPath, extrusionDepth: 0.15)
        backWall.firstMaterial = wallMat
        let bwn = SCNNode(geometry: backWall)
        bwn.position = SCNVector3(0, 0, backWallZ)
        bwn.physicsBody = .static()
        bwn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        room.addChildNode(bwn)
        
        let cupolaNode = SCNNode()
        cupolaNode.position = SCNVector3(0, 3.5, backWallZ)
        room.addChildNode(cupolaNode)
        let glassMat = SCNMaterial()
        glassMat.diffuse.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.15)
        glassMat.transparency = 0.2; glassMat.isDoubleSided = true
        let frameMat = SCNMaterial(); frameMat.diffuse.contents = UIColor(white: 0.3, alpha: 1) 
        let smoothFrameMat = SCNMaterial(); smoothFrameMat.diffuse.contents = UIColor(white: 0.25, alpha: 1) 
        let centerWindow = SCNCylinder(radius: 1.4, height: 0.05) 
        centerWindow.firstMaterial = glassMat
        let cwn = SCNNode(geometry: centerWindow)
        cwn.eulerAngles.x = .pi / 2
        cwn.position = SCNVector3(0, 0, -1.8) 
        cupolaNode.addChildNode(cwn)
        let innerRing = SCNTorus(ringRadius: 1.4, pipeRadius: 0.15)
        innerRing.firstMaterial = smoothFrameMat
        let irn = SCNNode(geometry: innerRing)
        irn.eulerAngles.x = .pi / 2
        irn.position = SCNVector3(0, 0, -1.8)
        cupolaNode.addChildNode(irn)
        let rWall: Float = 2.4
        let rCenter: Float = 1.4
        let zWall: Float = 0.0
        let zCenter: Float = -1.8
        let deltaR = rWall - rCenter
        let deltaZ = zCenter - zWall 
        let panelLength = sqrt(deltaR * deltaR + deltaZ * deltaZ)
        let pitchAngle = atan2(deltaR, -deltaZ)
        let avgRadius = (rWall + rCenter) / 2.0
        let panelWidth = (2.0 * Float.pi * avgRadius) / 6.0 - 0.1 
        for i in 0..<6 {
            let sliceNode = SCNNode()
            let yawAngle = Float(i) * (.pi / 3.0)
            sliceNode.eulerAngles.z = yawAngle
            let panel = SCNBox(width: 0.05, height: CGFloat(panelWidth), length: CGFloat(panelLength), chamferRadius: 0)
            panel.firstMaterial = glassMat
            let pn = SCNNode(geometry: panel)
            let midX = (rWall + rCenter) / 2.0
            let midZ = (zWall + zCenter) / 2.0
            pn.position = SCNVector3(midX, 0, midZ)
            pn.eulerAngles.y = pitchAngle
            sliceNode.addChildNode(pn)
            let strut = SCNBox(width: 0.15, height: 0.15, length: CGFloat(panelLength) + 0.1, chamferRadius: 0.02)
            strut.firstMaterial = frameMat
            let sn = SCNNode(geometry: strut)
            let strutNode = SCNNode()
            strutNode.eulerAngles.z = yawAngle - (.pi / 6.0) 
            sn.position = SCNVector3(midX, 0, midZ)
            sn.eulerAngles.y = pitchAngle
            strutNode.addChildNode(sn)
            cupolaNode.addChildNode(sliceNode)
            cupolaNode.addChildNode(strutNode)
        }
        let ringR: CGFloat = 2.5
        let pipeR: CGFloat = 0.3 
        let wallRing = SCNTorus(ringRadius: ringR, pipeRadius: pipeR)
        wallRing.firstMaterial = smoothFrameMat
        let wrn = SCNNode(geometry: wallRing); wrn.eulerAngles.x = .pi/2
        wrn.position = SCNVector3(0, 0, 0.1) 
        cupolaNode.addChildNode(wrn)
        let metalMat = SCNMaterial(); metalMat.diffuse.contents = UIColor(white: 0.7, alpha: 1); metalMat.metalness.contents = 0.9
        let darkMetalMat = SCNMaterial(); darkMetalMat.diffuse.contents = UIColor(white: 0.25, alpha: 1); darkMetalMat.metalness.contents = 0.95
        addEquipmentRack(to: room, at: SCNVector3(Float(-w/2) + 0.15, Float(h/2), -2.0), yRotation: .pi/2)
        addEquipmentRack(to: room, at: SCNVector3(Float(-w/2) + 0.15, Float(h/2), -4.0), yRotation: .pi/2)
        addEquipmentRack(to: room, at: SCNVector3(Float(w/2) - 0.15, Float(h/2), -2.0), yRotation: -.pi/2)
        addEquipmentRack(to: room, at: SCNVector3(Float(w/2) - 0.15, Float(h/2), -4.0), yRotation: -.pi/2)
        let screenBlueMat = SCNMaterial()
        screenBlueMat.diffuse.contents = UIColor(red: 0.02, green: 0.05, blue: 0.2, alpha: 1)
        screenBlueMat.emission.contents = UIColor(red: 0.0, green: 0.12, blue: 0.55, alpha: 1)
        let screenGreenMat = SCNMaterial()
        screenGreenMat.diffuse.contents = UIColor(red: 0.0, green: 0.12, blue: 0.04, alpha: 1)
        screenGreenMat.emission.contents = UIColor(red: 0.0, green: 0.5, blue: 0.2, alpha: 1)
        let scrLeft = SCNPlane(width: 1.2, height: 0.8)
        scrLeft.firstMaterial = screenBlueMat
        let sln = SCNNode(geometry: scrLeft)
        sln.position = SCNVector3(-2.8, 1.8, -5.5)
        sln.eulerAngles.y = .pi/6 
        room.addChildNode(sln)
        let bezelL = SCNBox(width: 1.3, height: 0.9, length: 0.05, chamferRadius: 0.02)
        bezelL.firstMaterial = darkMetalMat
        let bln = SCNNode(geometry: bezelL)
        bln.position = SCNVector3(-2.8, 1.8, -5.5)
        bln.eulerAngles.y = .pi/6
        room.addChildNode(bln)
        let scrRight = SCNPlane(width: 1.2, height: 0.8)
        scrRight.firstMaterial = screenGreenMat
        let srn = SCNNode(geometry: scrRight)
        srn.position = SCNVector3(2.8, 1.8, -5.5)
        srn.eulerAngles.y = -.pi/6
        room.addChildNode(srn)
        let bezelR = SCNBox(width: 1.3, height: 0.9, length: 0.05, chamferRadius: 0.02)
        bezelR.firstMaterial = darkMetalMat
        let brn = SCNNode(geometry: bezelR)
        brn.position = SCNVector3(2.8, 1.8, -5.5)
        brn.eulerAngles.y = -.pi/6
        room.addChildNode(brn)
        let teleNode = SCNNode()
        let tripodBase = SCNCylinder(radius: 0.05, height: 1.2)
        tripodBase.firstMaterial = darkMetalMat
        let tbN = SCNNode(geometry: tripodBase)
        tbN.position = SCNVector3(0, 0.6, 0)
        teleNode.addChildNode(tbN)
        let mainTube = SCNCylinder(radius: 0.15, height: 1.2)
        let whiteTubeMat = SCNMaterial(); whiteTubeMat.diffuse.contents = UIColor(white: 0.9, alpha: 1)
        mainTube.firstMaterial = whiteTubeMat
        let mtN = SCNNode(geometry: mainTube)
        mtN.eulerAngles.x = .pi/2 + 0.3 
        mtN.position = SCNVector3(0, 1.3, -0.2)
        teleNode.addChildNode(mtN)
        let eyepiece = SCNCylinder(radius: 0.03, height: 0.2)
        eyepiece.firstMaterial = darkMetalMat
        let epN = SCNNode(geometry: eyepiece)
        epN.eulerAngles.x = .pi/2 + 0.3
        epN.position = SCNVector3(0, 1.35, 0.45)
        teleNode.addChildNode(epN)
        let knob = SCNCylinder(radius: 0.04, height: 0.04)
        knob.firstMaterial = darkMetalMat
        let knN = SCNNode(geometry: knob)
        knN.eulerAngles.z = .pi/2
        knN.position = SCNVector3(0.08, 1.35, 0.35)
        teleNode.addChildNode(knN)
        let teleRing = SCNTorus(ringRadius: 0.15, pipeRadius: 0.02)
        teleRing.firstMaterial = darkMetalMat
        let trN = SCNNode(geometry: teleRing)
        trN.eulerAngles.x = .pi/2 + 0.3
        trN.position = SCNVector3(0, 1.13, -0.78)
        teleNode.addChildNode(trN)
        teleNode.position = SCNVector3(-1.8, 0, -4.5)
        room.addChildNode(teleNode)
        let camBase = SCNNode()
        let arm = SCNCylinder(radius: 0.03, height: 1.5)
        arm.firstMaterial = darkMetalMat
        let armN = SCNNode(geometry: arm)
        armN.position = SCNVector3(0, 0.75, 0)
        camBase.addChildNode(armN)
        let cBody = SCNBox(width: 0.25, height: 0.2, length: 0.35, chamferRadius: 0.02)
        cBody.firstMaterial = metalMat
        let cBodyN = SCNNode(geometry: cBody)
        cBodyN.position = SCNVector3(0, 1.5, -0.1)
        cBodyN.eulerAngles.x = 0.2 
        camBase.addChildNode(cBodyN)
        let cLens = SCNCylinder(radius: 0.08, height: 0.2)
        cLens.firstMaterial = darkMetalMat
        let clN = SCNNode(geometry: cLens)
        clN.eulerAngles.x = .pi/2
        clN.position = SCNVector3(0, 0, -0.2) 
        cBodyN.addChildNode(clN)
        let recLight = SCNSphere(radius: 0.02)
        let rlMat = SCNMaterial(); rlMat.diffuse.contents = UIColor.red; rlMat.emission.contents = UIColor.red
        recLight.firstMaterial = rlMat
        let rlN = SCNNode(geometry: recLight)
        rlN.position = SCNVector3(0.08, 0.1, 0.15)
        let fadeOut = SCNAction.fadeOpacity(to: 0.1, duration: 0.5)
        let fadeIn = SCNAction.fadeOpacity(to: 1.0, duration: 0.5)
        rlN.runAction(.repeatForever(.sequence([fadeOut, fadeIn])))
        cBodyN.addChildNode(rlN)
        camBase.position = SCNVector3(1.5, 0, -4.0)
        room.addChildNode(camBase)
        addRoomTrigger(to: room, name: "WindowRoomTrigger", width: w-1, depth: d-1, height: h)
        addRoomLight(to: room, height: h, color: UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1))
        return room
    }
    func distance(p1: SCNVector3, p2: SCNVector3) -> Float {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2) + pow(p2.z - p1.z, 2))
    }
    func makeEarthMaterial() -> SCNMaterial {
        let m = SCNMaterial()
        m.diffuse.contents = createDetailedEarthTexture()
        m.emission.contents = UIColor(red: 0.0, green: 0.02, blue: 0.06, alpha: 1)
        m.specular.contents = UIColor(white: 0.3, alpha: 1)
        return m
    }
    func createDetailedEarthTexture() -> UIImage {
        let sz = CGSize(width: 2048, height: 1024)
        UIGraphicsBeginImageContextWithOptions(sz, true, 1)
        guard let ctx = UIGraphicsGetCurrentContext() else { UIGraphicsEndImageContext(); return UIImage() }
        ctx.setFillColor(UIColor(red: 0.04, green: 0.15, blue: 0.45, alpha: 1).cgColor)
        ctx.fill(CGRect(origin: .zero, size: sz))
        ctx.setFillColor(UIColor(red: 0.06, green: 0.22, blue: 0.55, alpha: 0.6).cgColor)
        for _ in 0..<30 {
            let r = CGRect(x: .random(in: 0..<sz.width), y: .random(in: 0..<sz.height),
                           width: .random(in: 80...300), height: .random(in: 40...150))
            ctx.fillEllipse(in: r)
        }
        let landColors: [UIColor] = [
            UIColor(red: 0.12, green: 0.42, blue: 0.18, alpha: 1),
            UIColor(red: 0.18, green: 0.48, blue: 0.22, alpha: 1),
            UIColor(red: 0.35, green: 0.30, blue: 0.15, alpha: 1), 
            UIColor(red: 0.15, green: 0.38, blue: 0.15, alpha: 1),
        ]
        drawLandmass(ctx: ctx, pts: [(380,140),(420,120),(500,130),(520,180),(480,240),(430,280),(380,260),(360,200)], color: landColors[0])
        drawLandmass(ctx: ctx, pts: [(460,350),(490,320),(510,380),(520,480),(500,560),(470,600),(440,550),(430,420)], color: landColors[1])
        drawLandmass(ctx: ctx, pts: [(900,120),(960,100),(1020,130),(1040,180),(1000,200),(960,180)], color: landColors[0])
        drawLandmass(ctx: ctx, pts: [(920,250),(980,220),(1050,280),(1060,400),(1020,500),(960,480),(920,380)], color: landColors[2])
        drawLandmass(ctx: ctx, pts: [(1100,80),(1250,60),(1400,90),(1500,140),(1480,200),(1350,220),(1200,200),(1100,150)], color: landColors[3])
        drawLandmass(ctx: ctx, pts: [(1450,420),(1550,400),(1600,440),(1580,500),(1500,520),(1440,480)], color: landColors[2])
        ctx.setFillColor(UIColor(white: 0.95, alpha: 0.9).cgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: sz.width, height: 40))
        ctx.fill(CGRect(x: 0, y: sz.height - 50, width: sz.width, height: 50))
        ctx.setFillColor(UIColor(white: 1, alpha: 0.25).cgColor)
        for _ in 0..<80 {
            let r = CGRect(x: .random(in: 0..<sz.width), y: .random(in: 0..<sz.height),
                           width: .random(in: 40...200), height: .random(in: 15...50))
            ctx.fillEllipse(in: r)
        }
        ctx.setFillColor(UIColor(white: 1, alpha: 0.15).cgColor)
        for y in stride(from: CGFloat(100), through: sz.height - 100, by: 180) {
            ctx.fill(CGRect(x: 0, y: y, width: sz.width, height: .random(in: 20...60)))
        }
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext(); return img
    }
    func drawLandmass(ctx: CGContext, pts: [(CGFloat,CGFloat)], color: UIColor) {
        guard pts.count > 2 else { return }
        ctx.setFillColor(color.cgColor)
        ctx.beginPath(); ctx.move(to: CGPoint(x: pts[0].0, y: pts[0].1))
        for i in 1..<pts.count {
            let prev = pts[i-1], cur = pts[i]
            let cpx = (prev.0 + cur.0) / 2 + .random(in: -20...20)
            let cpy = (prev.1 + cur.1) / 2 + .random(in: -15...15)
            ctx.addQuadCurve(to: CGPoint(x: cur.0, y: cur.1), control: CGPoint(x: cpx, y: cpy))
        }
        ctx.closePath(); ctx.fillPath()
        ctx.setFillColor(color.withAlphaComponent(0.5).cgColor)
        for p in pts {
            ctx.fillEllipse(in: CGRect(x: p.0 - 30, y: p.1 - 20, width: 60, height: 40))
        }
    }
    func buildLogRoom(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "LogRoom"; room.position = pos
        let w: CGFloat = 6, d: CGFloat = 7, h: CGFloat = 3.5
        addRoomShell(to: room, width: w, depth: d, height: h)
        let desk = SCNBox(width: 3.5, height: 0.08, length: 1.5, chamferRadius: 0.02)
        desk.firstMaterial = panelMat
        let dn = SCNNode(geometry: desk); dn.position = SCNVector3(-1.50, 1.0, -6.0)
        addStaticPhysics(to: dn)
        room.addChildNode(dn)
        for (x, z) in [(-3.0, -5.4), (0.0, -5.4), (-3.0, -6.5), (0.0, -6.5)] as [(Float, Float)] {
            let leg = SCNCylinder(radius: 0.04, height: 1.0); leg.firstMaterial = darkMat
            let ln = SCNNode(geometry: leg); ln.position = SCNVector3(x, 0.5, z)
            addStaticPhysics(to: ln)
            room.addChildNode(ln)
        }
        let screenMaterial = SCNMaterial()
        let screenPlane = SCNPlane(width: 1.6, height: 1.0)
        screenPlane.firstMaterial = screenMaterial
        let screenN = SCNNode(geometry: screenPlane)
        screenN.name = "LogRoomScreen"
        screenN.eulerAngles = SCNVector3(-0.12, Float.pi, 0)
        screenN.position = SCNVector3(-1.70, 1.60, -6.37)
        room.addChildNode(screenN)
        let bezel = SCNBox(width: 1.68, height: 1.08, length: 0.05, chamferRadius: 0.03)
        bezel.firstMaterial = darkMat
        let bezelN = SCNNode(geometry: bezel)
        bezelN.position = SCNVector3(-1.70, 1.60, -6.41)
        bezelN.eulerAngles.x = -0.12
        room.addChildNode(bezelN)
        let standPole = SCNBox(width: 0.06, height: 0.28, length: 0.06, chamferRadius: 0.01)
        standPole.firstMaterial = darkMat
        let spn = SCNNode(geometry: standPole)
        spn.position = SCNVector3(-0.20, 1.18, -6.40)
        room.addChildNode(spn)
        let standBase = SCNBox(width: 0.45, height: 0.04, length: 0.28, chamferRadius: 0.02)
        standBase.firstMaterial = darkMat
        let sbn = SCNNode(geometry: standBase)
        sbn.position = SCNVector3(-0.20, 1.06, -6.40)
        room.addChildNode(sbn)
        let chairNode = SCNNode()
        chairNode.name = "LogRoomChair"
        chairNode.isHidden = false 
        let seat = SCNBox(width: 0.6, height: 0.06, length: 0.6, chamferRadius: 0.05)
        let chairMat = SCNMaterial(); chairMat.diffuse.contents = UIColor(white: 0.35, alpha: 1)
        seat.firstMaterial = chairMat
        let seatN = SCNNode(geometry: seat); seatN.position = SCNVector3(-1.50, 0.75, -5.5)
        addStaticPhysics(to: seatN)
        chairNode.addChildNode(seatN)
        let back = SCNBox(width: 0.6, height: 0.7, length: 0.06, chamferRadius: 0.05)
        back.firstMaterial = chairMat
        let backN = SCNNode(geometry: back); backN.position = SCNVector3(-1.50, 1.1, -5.2)
        addStaticPhysics(to: backN)
        chairNode.addChildNode(backN)
        let base = SCNCylinder(radius: 0.04, height: 0.75); base.firstMaterial = darkMat
        let baseN = SCNNode(geometry: base); baseN.position = SCNVector3(-1.50, 0.375, -5.5)
        addStaticPhysics(to: baseN)
        chairNode.addChildNode(baseN)
        room.addChildNode(chairNode)
        let camBody = SCNBox(width: 0.25, height: 0.2, length: 0.35, chamferRadius: 0.03)
        camBody.firstMaterial = darkMat
        let camN = SCNNode(geometry: camBody)
        camN.name = "CCTVCamera"
        
        let cctvRealCam = SCNCamera()
        cctvRealCam.fieldOfView = 75
        
        let povNode = SCNNode()
        povNode.camera = cctvRealCam
        povNode.eulerAngles.y = Float.pi 
        camN.addChildNode(povNode)
        
        camN.position = SCNVector3(-0.20, 1.42, -6.40)
        camN.eulerAngles.y = -0.3
        camN.eulerAngles.x = -0.3
        addStaticPhysics(to: camN)
        room.addChildNode(camN)
        let lens = SCNCylinder(radius: 0.06, height: 0.12)
        let lensMat = SCNMaterial(); lensMat.diffuse.contents = UIColor(white: 0.15, alpha: 1)
        lensMat.metalness.contents = 0.9; lens.firstMaterial = lensMat
        let lensN = SCNNode(geometry: lens); lensN.eulerAngles.x = .pi/2
        lensN.position = SCNVector3(0, 0, 0.18) 
        camN.addChildNode(lensN)
        let glass = SCNCylinder(radius: 0.05, height: 0.01)
        let glassMat = SCNMaterial(); glassMat.diffuse.contents = UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 0.8)
        glassMat.metalness.contents = 0.95; glass.firstMaterial = glassMat
        let glassN = SCNNode(geometry: glass); glassN.eulerAngles.x = .pi/2
        glassN.position = SCNVector3(0, 0, 0.24) 
        camN.addChildNode(glassN)
        let tripod = SCNCylinder(radius: 0.02, height: 1.5); tripod.firstMaterial = darkMat
        let tripN = SCNNode(geometry: tripod); tripN.position = SCNVector3(-1.35, 0.85, -6.2)
        room.addChildNode(tripN)
        let recL = SCNSphere(radius: 0.04)
        let rm = SCNMaterial(); rm.diffuse.contents = UIColor.red; rm.emission.contents = UIColor.red
        recL.firstMaterial = rm
        let rn = SCNNode(geometry: recL)
        rn.name = "RecLight" 
        rn.position = SCNVector3(0, 0.12, 0.15) 
        rn.opacity = 0.2 
        camN.addChildNode(rn)
        let sleepPodNode = SCNNode()
        sleepPodNode.name = "SleepPod"
        let podW: CGFloat = 2.8 
        let podH: CGFloat = 1.2 
        let podD: CGFloat = 1.4 
        let doorOpeningW: CGFloat = 2.4
        let doorOpeningH: CGFloat = 1.0
        let frameThick: CGFloat = 0.1
        let frameMat = wallMat
        let fLeft = SCNBox(width: (podW - doorOpeningW)/2, height: podH, length: frameThick, chamferRadius: 0.01)
        fLeft.firstMaterial = frameMat
        let fLNode = SCNNode(geometry: fLeft)
        fLNode.position = SCNVector3(-podW/2 + fLeft.width/2, podH/2, podD/2)
        sleepPodNode.addChildNode(fLNode)
        let fRight = SCNBox(width: (podW - doorOpeningW)/2, height: podH, length: frameThick, chamferRadius: 0.01)
        fRight.firstMaterial = frameMat
        let fRNode = SCNNode(geometry: fRight)
        fRNode.position = SCNVector3(podW/2 - fRight.width/2, podH/2, podD/2)
        sleepPodNode.addChildNode(fRNode)
        for hh in [podH - doorOpeningH, (podH - doorOpeningH)/2] { 
            let fTb = SCNBox(width: doorOpeningW, height: (podH - doorOpeningH)/2, length: frameThick, chamferRadius: 0.01)
            fTb.firstMaterial = frameMat
            let fTbN = SCNNode(geometry: fTb)
            fTbN.position = SCNVector3(0, hh == podH - doorOpeningH ? podH - fTb.height/2 : fTb.height/2, podD/2)
            sleepPodNode.addChildNode(fTbN)
        }
        let doorThick: CGFloat = 0.04
        let doorBox = SCNBox(width: doorOpeningW, height: doorOpeningH, length: doorThick, chamferRadius: 0.01)
        let doorMat = ceilingPadMat 
        doorBox.firstMaterial = doorMat
        let doorNode = SCNNode(geometry: doorBox)
        doorNode.position = SCNVector3(0, doorOpeningH/2 + 0.3, podD/2 - frameThick/2 - doorThick/2 - 0.01)
        sleepPodNode.addChildNode(doorNode)
        let podInteriorMat = SCNMaterial()
        podInteriorMat.diffuse.contents = UIColor(red: 0.7, green: 0.8, blue: 0.95, alpha: 1.0)
        podInteriorMat.roughness.contents = 0.9
        let intFloor = SCNBox(width: podW, height: 0.1, length: podD, chamferRadius: 0)
        intFloor.firstMaterial = podInteriorMat
        let ifNode = SCNNode(geometry: intFloor)
        ifNode.position = SCNVector3(0, 0.05, 0)
        sleepPodNode.addChildNode(ifNode)
        let intCeil = SCNBox(width: podW, height: 0.1, length: podD, chamferRadius: 0)
        intCeil.firstMaterial = podInteriorMat
        let icNode = SCNNode(geometry: intCeil)
        icNode.position = SCNVector3(0, podH - 0.05, 0)
        sleepPodNode.addChildNode(icNode)
        let intBack = SCNBox(width: podW, height: podH, length: 0.1, chamferRadius: 0)
        intBack.firstMaterial = podInteriorMat
        let ibNode = SCNNode(geometry: intBack)
        ibNode.position = SCNVector3(0, podH/2, -podD/2 + 0.05)
        sleepPodNode.addChildNode(ibNode)
        let intSide = SCNBox(width: 0.1, height: podH, length: podD, chamferRadius: 0)
        intSide.firstMaterial = podInteriorMat
        for sx in [-podW/2 + 0.05, podW/2 - 0.05] {
            let sn = SCNNode(geometry: intSide)
            sn.position = SCNVector3(sx, podH/2, 0)
            sleepPodNode.addChildNode(sn)
        }
        let bagW: CGFloat = 0.75 
        let bagH: CGFloat = 2.1 
        let bagGeo = SCNCapsule(capRadius: bagW/2, height: bagH)
        let bagMat = SCNMaterial()
        bagMat.diffuse.contents = UIColor(red: 0.1, green: 0.25, blue: 0.5, alpha: 1) 
        bagMat.roughness.contents = 0.85
        bagGeo.firstMaterial = bagMat
        let bagNode = SCNNode(geometry: bagGeo)
        bagNode.eulerAngles.z = .pi / 2
        bagNode.scale = SCNVector3(1, 1, 0.4) 
        bagNode.position = SCNVector3(0, 0.1 + bagW/2*0.4, 0) 
        sleepPodNode.addChildNode(bagNode)
        let strapMat = SCNMaterial()
        strapMat.diffuse.contents = UIColor(white: 0.8, alpha: 1)
        for sx in [-0.6, 0.1, 0.8] {
            let strap = SCNBox(width: 0.06, height: 0.02, length: bagW + 0.1, chamferRadius: 0.01)
            strap.firstMaterial = strapMat
            let stn = SCNNode(geometry: strap)
            stn.position = SCNVector3(Float(sx), 0.1 + Float(bagW/2*0.4) + 0.01, 0)
            sleepPodNode.addChildNode(stn)
        }
        let podLightBox = SCNBox(width: 0.2, height: 0.02, length: 0.1, chamferRadius: 0.01)
        let plMat = SCNMaterial()
        plMat.diffuse.contents = UIColor.white
        plMat.emission.contents = UIColor(white: 0.9, alpha: 1)
        podLightBox.firstMaterial = plMat
        let plNode = SCNNode(geometry: podLightBox)
        plNode.position = SCNVector3(0, podH - 0.1, 0)
        sleepPodNode.addChildNode(plNode)
        let podBlock = SCNBox(width: podW, height: podH, length: podD, chamferRadius: 0)
        podBlock.firstMaterial?.transparency = 0 
        let blockNode = SCNNode(geometry: podBlock)
        blockNode.position = SCNVector3(0, podH/2, 0)
        addStaticPhysics(to: blockNode)
        sleepPodNode.addChildNode(blockNode)
        sleepPodNode.position = SCNVector3(Float(w/2) - Float(podD/2) - 0.01, 0.5, Float(-d/2) + Float(podW/2) - 1.2)
        sleepPodNode.eulerAngles.y = -.pi / 2
        room.addChildNode(sleepPodNode)
        for _ in 0..<5 {
            let paper = SCNBox(width: 0.2, height: 0.005, length: 0.3, chamferRadius: 0)
            paper.firstMaterial?.diffuse.contents = UIColor.white
            let pn = SCNNode(geometry: paper)
            pn.position = SCNVector3(Float.random(in: -2.50 ... -0.50), 1.05, Float.random(in: -6.5 ... -5.5))
            pn.eulerAngles.y = Float.random(in: 0...6)
            room.addChildNode(pn)
        }
        addRoomTrigger(to: room, name: "LogTrigger", width: w-1, depth: d-1, height: h)
        addRoomLight(to: room, height: h, color: UIColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 1))
        return room
    }
    func buildZeroGRoom(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "ZeroGRoom"; room.position = pos
        let w: CGFloat = 8, d: CGFloat = 8, h: CGFloat = 6
        addRoomShell(to: room, width: w, depth: d, height: h)
        let geos: [(SCNGeometry, SCNVector3)] = [
            (SCNSphere(radius: 0.3), SCNVector3(-1,3,-3)),
            (SCNBox(width: 0.5,height: 0.5,length: 0.5,chamferRadius: 0.05), SCNVector3(1.5,2.5,-4)),
            (SCNSphere(radius: 0.2), SCNVector3(0,3.5,-5)),
            (SCNTorus(ringRadius: 0.3, pipeRadius: 0.08), SCNVector3(2,4.5,-3)),
        ]
        for (geo, p) in geos {
            let m = SCNMaterial()
            m.diffuse.contents = UIColor(red: .random(in: 0.3...0.8), green: .random(in: 0.3...0.8), blue: .random(in: 0.5...1.0), alpha: 1)
            m.metalness.contents = 0.5; geo.firstMaterial = m
            let n = SCNNode(geometry: geo); n.position = p
            n.physicsBody = .dynamic(); n.physicsBody?.mass = 0.5
            n.physicsBody?.categoryBitMask = PhysicsCategory.floatingObject
            n.runAction(.repeatForever(.sequence([
                .moveBy(x: 0, y: 0.3, z: 0, duration: .random(in: 2...4)),
                .moveBy(x: 0, y: -0.3, z: 0, duration: .random(in: 2...4))])))
            room.addChildNode(n)
        }
        addEquipmentRack(to: room, at: SCNVector3(Float(w/2 - 0.2), Float(h/2), -4), yRotation: -.pi/2)
        let ceilCollider = SCNBox(width: w, height: 0.3, length: d, chamferRadius: 0)
        let ceilColliderMat = SCNMaterial(); ceilColliderMat.transparency = 0
        ceilCollider.firstMaterial = ceilColliderMat
        let ccN = SCNNode(geometry: ceilCollider)
        ccN.position = SCNVector3(0, Float(h) + 0.15, Float(-d/2))
        ccN.physicsBody = .static(); ccN.physicsBody?.categoryBitMask = PhysicsCategory.wall
        room.addChildNode(ccN)
        addRoomTrigger(to: room, name: "ZeroGTrigger", width: w-1, depth: d-1, height: h)
        addRoomLight(to: room, height: h, color: UIColor(red: 0.6, green: 0.9, blue: 1.0, alpha: 1))
        return room
    }
    func buildAirlockRoom(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "AirlockRoom"; room.position = pos
        let w: CGFloat = 8, d: CGFloat = 11, h: CGFloat = 5
        addRoomShell(to: room, width: w, depth: d, height: h)
        let metalMat = SCNMaterial()
        metalMat.diffuse.contents = UIColor(white: 0.6, alpha: 1)
        metalMat.metalness.contents = 0.9; metalMat.roughness.contents = 0.2
        let darkMetalMat = SCNMaterial()
        darkMetalMat.diffuse.contents = UIColor(white: 0.22, alpha: 1)
        darkMetalMat.metalness.contents = 0.95
        let whitePanelMat = SCNMaterial()
        whitePanelMat.diffuse.contents = UIColor(white: 0.88, alpha: 1)
        whitePanelMat.roughness.contents = 0.55
        let yellowMat = SCNMaterial()
        yellowMat.diffuse.contents = UIColor(red: 0.96, green: 0.84, blue: 0.0, alpha: 1)
        let grabBarMat = SCNMaterial()
        grabBarMat.diffuse.contents = UIColor(red: 0.68, green: 0.88, blue: 0.32, alpha: 1) 
        let amberMat = SCNMaterial()
        amberMat.diffuse.contents = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1)
        amberMat.emission.contents  = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 1)
        let redLedMat = SCNMaterial()
        redLedMat.diffuse.contents  = UIColor(red: 1, green: 0.1, blue: 0, alpha: 1)
        redLedMat.emission.contents = UIColor(red: 1, green: 0.1, blue: 0, alpha: 1)
        let greenLedMat = SCNMaterial()
        greenLedMat.diffuse.contents  = UIColor(red: 0, green: 0.9, blue: 0.3, alpha: 1)
        greenLedMat.emission.contents = UIColor(red: 0, green: 0.9, blue: 0.3, alpha: 1)
        let o2TankMat = SCNMaterial()
        o2TankMat.diffuse.contents  = UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1)
        o2TankMat.metalness.contents = 0.85; o2TankMat.roughness.contents = 0.15
        let n2TankMat = SCNMaterial()
        n2TankMat.diffuse.contents  = UIColor(red: 0.88, green: 0.88, blue: 0.65, alpha: 1)
        n2TankMat.metalness.contents = 0.85; n2TankMat.roughness.contents = 0.15
        let lightPanelMat = SCNMaterial()
        lightPanelMat.diffuse.contents  = UIColor(white: 0.98, alpha: 1)
        lightPanelMat.emission.contents = UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1)
        for (px, pz): (Float, Float) in [(-1.8, -1.5), (1.8, -1.5),
                                          (-1.8, -3.5), (1.8, -3.5),
                                          (-1.8, -5.5), (1.8, -5.5)] {
            let panel = SCNBox(width: 1.4, height: 0.04, length: 0.7, chamferRadius: 0.02)
            panel.firstMaterial = lightPanelMat
            let pn = SCNNode(geometry: panel)
            pn.position = SCNVector3(px, Float(h) - 0.04, pz)
            room.addChildNode(pn)
        }
        let clLight = SCNBox(width: CGFloat(w) - 1.0, height: 0.04, length: 0.5, chamferRadius: 0.02)
        clLight.firstMaterial = lightPanelMat
        let clLN = SCNNode(geometry: clLight)
        clLN.position = SCNVector3(0, Float(h) - 0.04, -9.0)
        room.addChildNode(clLN)
        for (i, xOff): (Int, Float) in [(0, -2.0), (1, 0.0), (2, 2.0)] {
            let strip = SCNBox(width: 0.3, height: 0.04, length: 1.0, chamferRadius: 0.02)
            strip.firstMaterial = amberMat
            let sn = SCNNode(geometry: strip)
            sn.name = "AirlockWarningLight_\(i)"
            sn.position = SCNVector3(xOff, Float(h) - 0.05, -7.5)
            sn.opacity = 0.15
            room.addChildNode(sn)
        }
        let innerHatchRing = SCNTorus(ringRadius: 0.88, pipeRadius: 0.10)
        innerHatchRing.firstMaterial = metalMat
        let ihrN = SCNNode(geometry: innerHatchRing)
        ihrN.eulerAngles.x = .pi / 2
        ihrN.position = SCNVector3(0, 1.6, -7.0)
        room.addChildNode(ihrN)
        let partitionMat = whitePanelMat
        let leftPart = SCNBox(width: 3.1, height: h, length: 0.1, chamferRadius: 0)
        leftPart.firstMaterial = partitionMat
        let lpN = SCNNode(geometry: leftPart)
        lpN.position = SCNVector3(-2.45, Float(h)/2, -7.0)
        addStaticPhysics(to: lpN); room.addChildNode(lpN)
        let rightPart = SCNBox(width: 3.1, height: h, length: 0.1, chamferRadius: 0)
        rightPart.firstMaterial = partitionMat
        let rpN = SCNNode(geometry: rightPart)
        rpN.position = SCNVector3(2.45, Float(h)/2, -7.0)
        addStaticPhysics(to: rpN); room.addChildNode(rpN)
        let topH: CGFloat = h - 2.9
        let topPart = SCNBox(width: 3.1, height: topH, length: 0.1, chamferRadius: 0)
        topPart.firstMaterial = partitionMat
        let tpN = SCNNode(geometry: topPart)
        tpN.position = SCNVector3(0, 2.9 + Float(topH)/2, -7.0)
        addStaticPhysics(to: tpN); room.addChildNode(tpN)
        let botH: CGFloat = 0.7
        let botPart = SCNBox(width: 1.8, height: botH, length: 0.1, chamferRadius: 0)
        botPart.firstMaterial = partitionMat
        let bpN = SCNNode(geometry: botPart)
        bpN.position = SCNVector3(0, Float(botH)/2, -7.0)
        room.addChildNode(bpN)
        let flange = SCNTube(innerRadius: 0.88, outerRadius: 1.5, height: 0.10)
        flange.firstMaterial = partitionMat
        let fn = SCNNode(geometry: flange)
        fn.eulerAngles.x = .pi / 2
        fn.position = SCNVector3(0, 1.6, -7.0)
        room.addChildNode(fn)
        let hatch1Node = SCNNode()
        hatch1Node.name = "AirlockHatch1"
        hatch1Node.position = SCNVector3(-0.88, 1.6, -7.0) 
        let hatch1Geo = SCNCylinder(radius: 0.88, height: 0.1)
        let h1m = SCNMaterial()
        h1m.diffuse.contents = UIColor(white: 0.45, alpha: 1)
        hatch1Geo.firstMaterial = h1m
        let h1n = SCNNode(geometry: hatch1Geo)
        h1n.eulerAngles.x = .pi / 2
        h1n.position = SCNVector3(0.88, 0, 0) 
        h1n.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        h1n.physicsBody?.categoryBitMask = PhysicsCategory.wall
        hatch1Node.addChildNode(h1n)
        let windowGeo1 = SCNCylinder(radius: 0.25, height: 0.12)
        let winMat1 = SCNMaterial()
        winMat1.diffuse.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.8)
        winMat1.metalness.contents = 0.9; winMat1.roughness.contents = 0.1; winMat1.isDoubleSided = true
        windowGeo1.firstMaterial = winMat1
        let winN1 = SCNNode(geometry: windowGeo1)
        winN1.eulerAngles.x = .pi / 2
        winN1.position = SCNVector3(0.88, 0, 0) 
        hatch1Node.addChildNode(winN1)
        let handle1 = SCNTorus(ringRadius: 0.45, pipeRadius: 0.02)
        let handleMat1 = SCNMaterial()
        handleMat1.diffuse.contents = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) 
        handle1.firstMaterial = handleMat1
        let handleN1 = SCNNode(geometry: handle1)
        handleN1.eulerAngles.x = .pi / 2
        handleN1.position = SCNVector3(0.88, 0, 0.08) 
        hatch1Node.addChildNode(handleN1)
        room.addChildNode(hatch1Node)
        for (zi, zOff): (Int, Float) in [(0, -0.5), (1, -0.8), (2, -1.1)] {
            let stripe = SCNPlane(width: w - 0.2, height: 0.25)
            let stm = SCNMaterial()
            stm.diffuse.contents = zi % 2 == 0
                ? UIColor(red: 0.96, green: 0.84, blue: 0.0, alpha: 1)
                : UIColor(white: 0.12, alpha: 1)
            stripe.firstMaterial = stm
            let stripeN = SCNNode(geometry: stripe)
            stripeN.eulerAngles.x = -.pi / 2
            stripeN.position = SCNVector3(0, 0.015, zOff)
            room.addChildNode(stripeN)
        }
        for (zi, zOff): (Int, Float) in [(0,-7.2),(1,-7.5),(2,-7.8),(3,-8.1),(4,-8.4)] {
            let stripe = SCNPlane(width: w - 0.2, height: 0.25)
            let stm = SCNMaterial()
            stm.diffuse.contents = zi % 2 == 0
                ? UIColor(red: 0.96, green: 0.84, blue: 0.0, alpha: 1)
                : UIColor(white: 0.12, alpha: 1)
            stripe.firstMaterial = stm
            let stripeN = SCNNode(geometry: stripe)
            stripeN.eulerAngles.x = -.pi / 2
            stripeN.position = SCNVector3(0, 0.015, zOff)
            room.addChildNode(stripeN)
        }
        let tankPositions: [(Float, SCNMaterial, Float)] = [
            (-2.8, o2TankMat, -10.7), (-1.8, o2TankMat, -10.7),
            (1.8, n2TankMat, -10.7),  (2.8, n2TankMat, -10.7)
        ]
        for (tx, mat, tz) in tankPositions {
            let tank = SCNCylinder(radius: 0.28, height: 1.8)
            tank.firstMaterial = mat
            let tN = SCNNode(geometry: tank)
            tN.position = SCNVector3(tx, 1.8, tz)
            addStaticPhysics(to: tN); room.addChildNode(tN)
            let cap = SCNSphere(radius: 0.28); cap.firstMaterial = mat
            let capN = SCNNode(geometry: cap)
            capN.position = SCNVector3(tx, 2.7, tz)
            room.addChildNode(capN)
            let valve = SCNCylinder(radius: 0.06, height: 0.2)
            valve.firstMaterial = darkMetalMat
            let vN = SCNNode(geometry: valve)
            vN.position = SCNVector3(tx, 3.0, tz)
            room.addChildNode(vN)
        }
        let tankLabelBar = SCNBox(width: CGFloat(w) - 0.4, height: 0.15, length: 0.06, chamferRadius: 0.02)
        tankLabelBar.firstMaterial = whitePanelMat
        let tlbN = SCNNode(geometry: tankLabelBar)
        tlbN.position = SCNVector3(0, 3.3, Float(-d + 0.15))
        room.addChildNode(tlbN)
        for (si, pz): (Int, Float) in [(0, -1.8), (1, -3.2)] {
            let eddaBack = SCNBox(width: 0.1, height: 1.8, length: 0.8, chamferRadius: 0.02)
            eddaBack.firstMaterial = whitePanelMat
            let ebN = SCNNode(geometry: eddaBack)
            ebN.position = SCNVector3(-2.8, 1.6, pz)
            room.addChildNode(ebN)
            let bracket = SCNBox(width: 0.5, height: 0.05, length: 0.6, chamferRadius: 0.01)
            bracket.firstMaterial = darkMetalMat
            let brN = SCNNode(geometry: bracket)
            brN.position = SCNVector3(-2.55, 1.8, pz)
            room.addChildNode(brN)
            for (hx, hz) in [(0.2, 0.15), (0.2, -0.15)] {
                let hose = SCNCylinder(radius: 0.018, height: 0.5) 
                hose.firstMaterial = yellowMat
                let hoseN = SCNNode(geometry: hose)
                hoseN.eulerAngles.z = .pi / 6 
                hoseN.position = SCNVector3(-2.45 + Float(hx), 1.6, pz + Float(hz)) 
                room.addChildNode(hoseN)
            }
            let suit = buildSpaceSuit()
            suit.name = "SpaceSuit_\(si)" 
            suit.position = SCNVector3(-2.0, 0.1, pz) 
            suit.eulerAngles.y = .pi / 2 
            room.addChildNode(suit)
        }
        let ceilRail = SCNCylinder(radius: 0.028, height: CGFloat(d) - 1.0)
        ceilRail.firstMaterial = grabBarMat
        let crN = SCNNode(geometry: ceilRail)
        crN.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)  
        crN.position = SCNVector3(0, Float(h) - 0.3, Float(-d/2))
        room.addChildNode(crN)
        for side: Float in [-Float(w/2) + 0.12, Float(w/2) - 0.12] {
            for gz: Float in [-2.0, -4.5, -7.5, -9.5] {
                let bar = SCNCylinder(radius: 0.025, height: 1.5)
                bar.firstMaterial = grabBarMat
                let barN = SCNNode(geometry: bar)
                barN.position = SCNVector3(side, 1.8, gz)
                room.addChildNode(barN)
            }
        }
        for gz: Float in [-7.5, -9.5] {
            let xBar = SCNCylinder(radius: 0.025, height: CGFloat(w) - 0.5)
            xBar.firstMaterial = grabBarMat
            let xN = SCNNode(geometry: xBar)
            xN.eulerAngles.z = .pi / 2
            xN.position = SCNVector3(0, Float(h) - 0.4, gz)
            room.addChildNode(xN)
        }
        let bagMat = SCNMaterial()
        bagMat.diffuse.contents = UIColor(red: 0.52, green: 0.60, blue: 0.48, alpha: 1)
        bagMat.roughness.contents = 0.88
        let bagData: [(CGFloat, CGFloat, SCNVector3)] = [
            (0.65, 0.45, SCNVector3(Float(w/2) - 0.42, 0.35, -1.0)),
            (0.65, 0.55, SCNVector3(Float(w/2) - 0.42, 0.90, -1.0)),
            (0.55, 0.40, SCNVector3(Float(w/2) - 0.42, 1.40, -1.0)),
            (0.50, 0.38, SCNVector3(Float(w/2) - 0.42, 0.30, -2.0)),
            (0.60, 0.50, SCNVector3(Float(w/2) - 0.42, 0.82, -2.0)),
        ]
        for (bw, bh, bpos) in bagData {
            let bag = SCNBox(width: 0.38, height: bh, length: bw, chamferRadius: 0.07)
            bag.firstMaterial = bagMat
            let bN = SCNNode(geometry: bag); bN.position = bpos
            addStaticPhysics(to: bN); room.addChildNode(bN)
        }
        let strapMat = SCNMaterial(); strapMat.diffuse.contents = UIColor(white: 0.85, alpha: 1)
        for sz: Float in [0.35, 0.90, 1.40] {
            let strap = SCNBox(width: 0.04, height: 0.03, length: 0.7, chamferRadius: 0.01)
            strap.firstMaterial = strapMat
            let stN = SCNNode(geometry: strap); stN.position = SCNVector3(Float(w/2) - 0.22, sz, -1.0)
            room.addChildNode(stN)
        }
        let hatchNode = SCNNode()
        hatchNode.name = "AirlockHatch2"
        hatchNode.position = SCNVector3(0, 2.0, Float(-d))
        let hatchGeo = SCNCylinder(radius: 1.0, height: 0.20)
        let hm = SCNMaterial()
        hm.diffuse.contents = UIColor(white: 0.42, alpha: 1)
        hm.metalness.contents = 0.95; hm.roughness.contents = 0.12
        hatchGeo.firstMaterial = hm
        if let backWall = room.childNode(withName: "Wall_Back", recursively: false) {
            backWall.isHidden = true
            backWall.physicsBody = nil
        }
        if let frontLeftWall = room.childNode(withName: "Wall_Front_Left", recursively: false) {
            frontLeftWall.isHidden = false
            frontLeftWall.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            frontLeftWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        }
        hatchNode.position = SCNVector3(-1.0, 2.0, Float(-d) + 0.1)
        let hatchGroup = SCNNode()
        hatchGroup.position = SCNVector3(1.0, 0, 0) 
        hatchNode.addChildNode(hatchGroup)
        let hatchDisc = SCNNode(geometry: hatchGeo)
        hatchDisc.eulerAngles.x = .pi / 2
        hatchGroup.addChildNode(hatchDisc)
        hatchDisc.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        hatchDisc.physicsBody?.categoryBitMask = PhysicsCategory.wall
        let windowGeo2 = SCNCylinder(radius: 0.30, height: 0.22)
        let winMat2 = SCNMaterial()
        winMat2.diffuse.contents = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.8)
        winMat2.metalness.contents = 0.9; winMat2.roughness.contents = 0.1; winMat2.isDoubleSided = true
        windowGeo2.firstMaterial = winMat2
        let winN2 = SCNNode(geometry: windowGeo2)
        winN2.eulerAngles.x = .pi / 2
        hatchGroup.addChildNode(winN2)
        let handle2 = SCNTorus(ringRadius: 0.50, pipeRadius: 0.02)
        let handleMat2 = SCNMaterial()
        handleMat2.diffuse.contents = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) 
        handle2.firstMaterial = handleMat2
        let handleN2 = SCNNode(geometry: handle2)
        handleN2.eulerAngles.x = .pi / 2
        handleN2.position = SCNVector3(0, 0, 0.12) 
        hatchGroup.addChildNode(handleN2)
        let outerRing = SCNTorus(ringRadius: 0.98, pipeRadius: 0.07)
        let ormMat = SCNMaterial()
        ormMat.diffuse.contents = UIColor(white: 0.58, alpha: 1); ormMat.metalness.contents = 0.9
        outerRing.firstMaterial = ormMat
        let outerRingN = SCNNode(geometry: outerRing)
        outerRingN.eulerAngles.x = .pi / 2
        hatchGroup.addChildNode(outerRingN)
        let hub = SCNCylinder(radius: 0.11, height: 0.12)
        hub.firstMaterial = darkMetalMat
        let hubN = SCNNode(geometry: hub)
        hubN.eulerAngles.x = .pi / 2
        hubN.position = SCNVector3(0, 0, -0.14)
        hatchGroup.addChildNode(hubN)
        let spokeMat = SCNMaterial()
        spokeMat.diffuse.contents = UIColor(white: 0.62, alpha: 1); spokeMat.metalness.contents = 0.82
        for si in 0..<4 {
            let spoke = SCNCylinder(radius: 0.028, height: 0.82)
            spoke.firstMaterial = spokeMat
            let spN = SCNNode(geometry: spoke)
            spN.eulerAngles.z = Float(si) * .pi / 2
            spN.position = SCNVector3(0, 0, -0.14)
            hatchGroup.addChildNode(spN)
        }
        let boltMat = SCNMaterial()
        boltMat.diffuse.contents = UIColor(white: 0.72, alpha: 1); boltMat.metalness.contents = 1.0
        for bi in 0..<6 {
            let bAngle = Float(bi) * .pi * 2.0 / 6.0
            let bolt = SCNCylinder(radius: 0.055, height: 0.14)
            bolt.firstMaterial = boltMat
            let bN = SCNNode(geometry: bolt)
            bN.eulerAngles.x = .pi / 2
            bN.position = SCNVector3(cos(bAngle) * 0.85, sin(bAngle) * 0.85, -0.14)
            hatchGroup.addChildNode(bN)
        }
        room.addChildNode(hatchNode)
        let outerPartitionMat = whitePanelMat
        let pZ = Float(-d)
        let outerLeftPart = SCNBox(width: 3.0, height: h, length: 0.1, chamferRadius: 0)
        outerLeftPart.firstMaterial = outerPartitionMat
        let olpN = SCNNode(geometry: outerLeftPart)
        olpN.position = SCNVector3(-2.5, Float(h)/2, pZ)
        addStaticPhysics(to: olpN); room.addChildNode(olpN)
        let outerRightPart = SCNBox(width: 3.0, height: h, length: 0.1, chamferRadius: 0)
        outerRightPart.firstMaterial = outerPartitionMat
        let orpN = SCNNode(geometry: outerRightPart)
        orpN.position = SCNVector3(2.5, Float(h)/2, pZ)
        addStaticPhysics(to: orpN); room.addChildNode(orpN)
        let outerTopH: CGFloat = 1.0
        let outerTopPart = SCNBox(width: 2.0, height: outerTopH, length: 0.1, chamferRadius: 0)
        outerTopPart.firstMaterial = outerPartitionMat
        let otpN = SCNNode(geometry: outerTopPart)
        otpN.position = SCNVector3(0, 3.5, pZ)
        addStaticPhysics(to: otpN); room.addChildNode(otpN)
        let outerBotH: CGFloat = 1.0
        let outerBotPart = SCNBox(width: 2.0, height: outerBotH, length: 0.1, chamferRadius: 0)
        outerBotPart.firstMaterial = outerPartitionMat
        let obpN = SCNNode(geometry: outerBotPart)
        obpN.position = SCNVector3(0, 0.5, pZ)
        room.addChildNode(obpN)
        let outerFlange = SCNTube(innerRadius: 1.05, outerRadius: 1.5, height: 0.10)
        outerFlange.firstMaterial = outerPartitionMat
        let ofn = SCNNode(geometry: outerFlange)
        ofn.eulerAngles.x = .pi / 2
        ofn.position = SCNVector3(0, 2.0, pZ)
        room.addChildNode(ofn)
        addRoomTrigger(to: room, name: "SuitUpTrigger", width: w-1, depth: 3, height: h)
        if let st = room.childNode(withName: "SuitUpTrigger", recursively: false) { st.position.z = -2.5 }
        addRoomTrigger(to: room, name: "Hatch1Trigger", width: 4, depth: 2, height: h)
        if let h1 = room.childNode(withName: "Hatch1Trigger", recursively: false) { h1.position = SCNVector3(0, h/2, -5.5) }
        addRoomTrigger(to: room, name: "ChamberTrigger", width: w-1, depth: 2, height: h)
        if let chl = room.childNode(withName: "ChamberTrigger", recursively: false) { chl.position = SCNVector3(0, h/2, -8.5) }
        addRoomTrigger(to: room, name: "Hatch2Trigger", width: 4, depth: 1.5, height: h)
        if let h2 = room.childNode(withName: "Hatch2Trigger", recursively: false) { h2.position = SCNVector3(0, h/2, -10.0) }
        addRoomLight(to: room, height: h, color: UIColor(red: 0.88, green: 0.94, blue: 1.0, alpha: 1))
        return room
    }
    func buildSpaceSuit() -> SCNNode {
        let suit = SCNNode()
        let bm = SCNMaterial()
        bm.diffuse.contents = UIColor.white; bm.metalness.contents = 0.3; bm.roughness.contents = 0.5
        let torso = SCNCapsule(capRadius: 0.35, height: 1.2); torso.firstMaterial = bm
        let tn = SCNNode(geometry: torso); tn.position.y = 1.5; suit.addChildNode(tn)
        addStaticPhysics(to: tn)
        for (ax, az): (Float, Float) in [(-0.45, 0.05), (0.45, 0.05)] {
            let arm = SCNCapsule(capRadius: 0.1, height: 0.7); arm.firstMaterial = bm
            let an = SCNNode(geometry: arm)
            an.eulerAngles.z = ax > 0 ? -0.4 : 0.4
            an.position = SCNVector3(ax, 1.45, az)
            suit.addChildNode(an)
        }
        for lx: Float in [-0.18, 0.18] {
            let leg = SCNCapsule(capRadius: 0.12, height: 0.85); leg.firstMaterial = bm
            let ln = SCNNode(geometry: leg); ln.position = SCNVector3(lx, 0.65, 0)
            suit.addChildNode(ln)
        }
        let pack = SCNBox(width: 0.52, height: 0.72, length: 0.32, chamferRadius: 0.05)
        pack.firstMaterial = bm
        let pn = SCNNode(geometry: pack); pn.position = SCNVector3(0, 1.52, 0.34)
        suit.addChildNode(pn)
        addStaticPhysics(to: pn)
        let helmet = SCNSphere(radius: 0.36)
        let vm = SCNMaterial()
        vm.diffuse.contents = UIColor(red: 0.82, green: 0.65, blue: 0.08, alpha: 0.55)
        vm.metalness.contents = 0.9; vm.roughness.contents = 0.05
        helmet.firstMaterial = vm
        let hmn = SCNNode(geometry: helmet); hmn.position.y = 2.3; suit.addChildNode(hmn)
        addStaticPhysics(to: hmn)
        let visorRim = SCNTorus(ringRadius: 0.36, pipeRadius: 0.025)
        let vrm = SCNMaterial(); vrm.diffuse.contents = UIColor(white: 0.6, alpha: 1); vrm.metalness.contents = 0.95
        visorRim.firstMaterial = vrm
        let vrmN = SCNNode(geometry: visorRim); vrmN.position.y = 2.3
        suit.addChildNode(vrmN)
        return suit
    }
    func buildTechRoom(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "TechRoom"; room.position = pos
        let w: CGFloat = 8, d: CGFloat = 8, h: CGFloat = 3.5
        addRoomShell(to: room, width: w, depth: d, height: h)
        let missions = ["APOLLO 11","HUBBLE","ISS","MARS ROVER","JAMES WEBB","ARTEMIS"]
        let scrW: CGFloat = 1.55, scrH: CGFloat = 1.05, bezD: CGFloat = 0.12, scrDepth: CGFloat = 0.02
        for (i, mission) in missions.enumerated() {
            let col = i % 3
            let row = i / 3
            let cx = Float(col) * 2.2 - 2.2
            let cy: Float = row == 0 ? 2.25 : 1.0
            let cz = Float(-d) + Float(bezD) / 2 + 0.01
            let bezelGeo = SCNBox(width: scrW + 0.12, height: scrH + 0.1, length: bezD, chamferRadius: 0.04)
            let bezMat = SCNMaterial()
            bezMat.diffuse.contents = UIColor(white: 0.12, alpha: 1)
            bezMat.metalness.contents = 0.6; bezMat.roughness.contents = 0.4
            bezelGeo.firstMaterial = bezMat
            let bezelN = SCNNode(geometry: bezelGeo)
            bezelN.position = SCNVector3(cx, cy, cz)
            bezelN.name = "Screen_\(mission)"
            room.addChildNode(bezelN)
            let faceGeo = SCNBox(width: scrW, height: scrH, length: scrDepth, chamferRadius: 0.02)
            let faceMat = SCNMaterial()
            faceMat.diffuse.contents  = UIColor(red: 0.02, green: 0.06, blue: 0.18, alpha: 1)
            faceMat.emission.contents = UIColor(red: 0.02, green: 0.06, blue: 0.18, alpha: 1)
            faceGeo.firstMaterial = faceMat
            let faceN = SCNNode(geometry: faceGeo)
            faceN.position = SCNVector3(cx, cy, cz - Float(bezD)/2 - Float(scrDepth)/2)
            room.addChildNode(faceN)
            let lbl = SCNText(string: mission, extrusionDepth: 0.018)
            lbl.font = UIFont.systemFont(ofSize: 0.13, weight: .bold)
            lbl.flatness = 0.2
            let lblFaceMat = SCNMaterial()
            lblFaceMat.diffuse.contents  = UIColor.cyan
            lblFaceMat.emission.contents = UIColor(red: 0, green: 0.7, blue: 0.7, alpha: 1)
            lbl.firstMaterial = lblFaceMat
            let ln = SCNNode(geometry: lbl)
            let (mn, mx2) = ln.boundingBox
            let textW = mx2.x - mn.x
            ln.position = SCNVector3(
                cx - textW / 2,
                cy + Float(scrH) / 2 - 0.25,
                cz + Float(bezD)/2 + Float(scrDepth)/2 + 0.01 
            )
            room.addChildNode(ln)
            let armGeo = SCNBox(width: 0.08, height: 0.08, length: 0.06, chamferRadius: 0.01)
            let armMat = SCNMaterial(); armMat.diffuse.contents = UIColor(white: 0.3, alpha: 1)
            armGeo.firstMaterial = armMat
            let armN = SCNNode(geometry: armGeo)
            armN.position = SCNVector3(cx, cy, Float(-d) + 0.01)
            room.addChildNode(armN)
        }
        for (i, mission) in missions.enumerated() {
            let col = i % 3
            let row = i / 3
            let cz = -2.0 - Float(col) * 2.2 
            let cy: Float = row == 0 ? 2.25 : 1.0
            let cx = Float(-w / 2) + Float(bezD) / 2 + 0.02
            let bezelGeo = SCNBox(width: scrW + 0.12, height: scrH + 0.1, length: bezD, chamferRadius: 0.04)
            let bezMat = SCNMaterial()
            bezMat.diffuse.contents = UIColor(white: 0.12, alpha: 1)
            bezMat.metalness.contents = 0.6; bezMat.roughness.contents = 0.4
            bezelGeo.firstMaterial = bezMat
            let bezelN = SCNNode(geometry: bezelGeo)
            bezelN.position = SCNVector3(cx, cy, cz)
            bezelN.eulerAngles.y = .pi / 2
            room.addChildNode(bezelN)
            let faceGeo = SCNBox(width: scrW, height: scrH, length: scrDepth, chamferRadius: 0.02)
            let faceMat = SCNMaterial()
            faceMat.diffuse.contents  = UIColor(red: 0.02, green: 0.06, blue: 0.18, alpha: 1)
            faceMat.emission.contents = UIColor(red: 0.02, green: 0.06, blue: 0.18, alpha: 1)
            faceGeo.firstMaterial = faceMat
            let faceN = SCNNode(geometry: faceGeo)
            faceN.position = SCNVector3(cx + Float(bezD)/2 + Float(scrDepth)/2, cy, cz)
            faceN.eulerAngles.y = .pi / 2
            room.addChildNode(faceN)
            let lbl = SCNText(string: mission, extrusionDepth: 0.018)
            lbl.font = UIFont.systemFont(ofSize: 0.13, weight: .bold)
            lbl.flatness = 0.2
            let lblFaceMat = SCNMaterial()
            lblFaceMat.diffuse.contents  = UIColor.cyan
            lblFaceMat.emission.contents = UIColor(red: 0, green: 0.7, blue: 0.7, alpha: 1)
            lbl.firstMaterial = lblFaceMat
            let ln = SCNNode(geometry: lbl)
            let (mn, mx2) = ln.boundingBox
            let textW = mx2.x - mn.x
            ln.position = SCNVector3(
                cx + Float(bezD)/2 + Float(scrDepth) + 0.01,
                cy + Float(scrH) / 2 - 0.25,
                cz + Float(textW) / 2
            )
            ln.eulerAngles.y = .pi / 2
            room.addChildNode(ln)
            let armGeo = SCNBox(width: 0.08, height: 0.08, length: 0.06, chamferRadius: 0.01)
            let armMat = SCNMaterial(); armMat.diffuse.contents = UIColor(white: 0.3, alpha: 1)
            armGeo.firstMaterial = armMat
            let armN = SCNNode(geometry: armGeo)
            armN.position = SCNVector3(Float(-w/2) + 0.01, cy, cz)
            armN.eulerAngles.y = .pi / 2
            room.addChildNode(armN)
        }
        addEquipmentRack(to: room, at: SCNVector3(-3.9, Float(h/2), -1.2), yRotation: .pi/2)
        addEquipmentRack(to: room, at: SCNVector3(-3.9, Float(h/2), -2.2), yRotation: .pi/2)
        for i in 0..<4 {
             let rack = SCNBox(width: 0.6, height: 2.5, length: 0.8, chamferRadius: 0.05)
             rack.firstMaterial = darkMat
             let rn = SCNNode(geometry: rack)
             rn.position = SCNVector3(3.7, 1.25, Float(-1.5 - Float(i)*1.5))
             addStaticPhysics(to: rn)
             room.addChildNode(rn)
             for _ in 0..<5 {
                 let light = SCNSphere(radius: 0.02)
                 let lm = SCNMaterial(); lm.emission.contents = UIColor.green
                 light.firstMaterial = lm
                 let ln = SCNNode(geometry: light)
                 ln.position = SCNVector3(-0.3, Float.random(in: -1.0...1.0), Float.random(in: -0.3...0.3)) 
                 rn.addChildNode(ln)
             }
        }
        addRoomTrigger(to: room, name: "TechTrigger", width: w-1, depth: d-1, height: h)
        addRoomLight(to: room, height: h, color: UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1))
        return room
    }
    func addRoomShell(to room: SCNNode, width w: CGFloat, depth d: CGFloat, height h: CGFloat) {
        let floor = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); floor.firstMaterial = floorMat
        let fn = SCNNode(geometry: floor); fn.position = SCNVector3(0, 0, Float(-d/2))
        fn.physicsBody = .static(); fn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(fn)
        let ceil = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); ceil.firstMaterial = ceilingPadMat
        let cn = SCNNode(geometry: ceil); cn.position = SCNVector3(0, Float(h), Float(-d/2))
        cn.physicsBody = .static(); cn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(cn)
        let walls: [(String, CGFloat, CGFloat, CGFloat, SCNVector3)] = [
            ("Wall_Back", w, h, 0.15, SCNVector3(0, Float(h/2), Float(-d))),
            ("Wall_Left", 0.15, h, d, SCNVector3(Float(-w/2), Float(h/2), Float(-d/2))),
            ("Wall_Right", 0.15, h, d, SCNVector3(Float(w/2), Float(h/2), Float(-d/2))),
        ]
        for (name, ww, hh, ll, p) in walls {
            let box = SCNBox(width: ww, height: hh, length: ll, chamferRadius: 0); box.firstMaterial = wallMat
            let n = SCNNode(geometry: box); n.position = p; n.name = name
            n.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            n.physicsBody?.categoryBitMask = PhysicsCategory.wall
            room.addChildNode(n)
        }
        let openingWidth: CGFloat = 3.0
        let segmentWidth = (w - openingWidth) / 2.0
        if segmentWidth > 0.05 {
            for side: CGFloat in [-1, 1] {
                let fw = SCNBox(width: segmentWidth, height: h, length: 0.15, chamferRadius: 0)
                fw.firstMaterial = wallMat
                let fwn = SCNNode(geometry: fw)
                fwn.name = "Wall_Front_\(side > 0 ? "Right" : "Left")"
                let xOff = side * (openingWidth / 2.0 + segmentWidth / 2.0)
                fwn.position = SCNVector3(Float(xOff), Float(h / 2), 0)
                fwn.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
                fwn.physicsBody?.categoryBitMask = PhysicsCategory.wall
                room.addChildNode(fwn)
                let rail = SCNCylinder(radius: 0.016, height: segmentWidth)
                rail.firstMaterial = blueMat
                let rn = SCNNode(geometry: rail)
                rn.eulerAngles.z = .pi / 2
                rn.position = SCNVector3(Float(xOff), 1.6, -0.15) 
                room.addChildNode(rn)
            }
        }
        let passageHeight: CGFloat = 3.5
        if h > passageHeight {
            let headerH = h - passageHeight
            let header = SCNBox(width: openingWidth, height: headerH, length: 0.15, chamferRadius: 0)
            header.firstMaterial = wallMat
            let hn = SCNNode(geometry: header)
            hn.position = SCNVector3(0, Float(passageHeight + headerH / 2), 0)
            hn.physicsBody = .static(); hn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            room.addChildNode(hn)
        }
    }
    func addRoomTrigger(to room: SCNNode, name: String, width: CGFloat, depth: CGFloat, height: CGFloat) {
        let t = SCNBox(width: width, height: height, length: depth, chamferRadius: 0)
        t.firstMaterial = SCNMaterial(); t.firstMaterial?.transparency = 0.0
        let tn = SCNNode(geometry: t); tn.name = name
        tn.position = SCNVector3(0, Float(height/2), Float(-depth/2))
        tn.physicsBody = .static(); tn.physicsBody?.categoryBitMask = PhysicsCategory.trigger
        tn.physicsBody?.contactTestBitMask = PhysicsCategory.player; tn.physicsBody?.collisionBitMask = 0
        room.addChildNode(tn)
    }
    func addRoomLight(to room: SCNNode, height: CGFloat, color: UIColor) {
        let l = SCNLight(); l.type = .omni; l.color = color; l.intensity = 450 
        l.attenuationStartDistance = 2; l.attenuationEndDistance = 12
        let n = SCNNode(); n.light = l; n.position = SCNVector3(0, Float(height - 0.3), -3)
        n.name = "\(room.name ?? "Room")Light"
        room.addChildNode(n)
    }
    func addRandomCables(to parent: SCNNode, length: CGFloat, width: CGFloat, height: CGFloat) {
        let count = 12
        for _ in 0..<count {
            let isLeft = Bool.random()
            let xStart = Float.random(in: Float(-length/2)...Float(length/2))
            let zPos = isLeft ? Float(-width/2 + 0.2) : Float(width/2 - 0.2)
            var points: [SCNVector3] = []
            var curr = SCNVector3(xStart, Float.random(in: 1.0...4.0), zPos)
            points.append(curr)
            for _ in 0..<4 {
                curr.x += Float.random(in: 1.0...3.0)
                curr.y += Float.random(in: -0.5...0.5)
                curr.z += Float.random(in: -0.1...0.1) 
                points.append(curr)
            }
            for i in 0..<points.count-1 {
                let p1 = points[i]
                let p2 = points[i+1]
                let dist = distance(p1: p1, p2: p2)
                let cyl = SCNCylinder(radius: 0.008, height: CGFloat(dist)) 
                cyl.firstMaterial = cableMat
                let node = SCNNode(geometry: cyl)
                node.position = SCNVector3((p1.x+p2.x)/2, (p1.y+p2.y)/2, (p1.z+p2.z)/2)
                node.look(at: p2, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
                parent.addChildNode(node)
                if i > 0 && Bool.random() {
                    let tie = SCNCylinder(radius: 0.015, height: 0.05)
                    tie.firstMaterial?.diffuse.contents = UIColor.black
                    let tn = SCNNode(geometry: tie)
                    tn.position = p1
                    tn.eulerAngles.z = .pi/2
                    parent.addChildNode(tn)
                }
            }
        }
    }
    func addCasualCargo(to parent: SCNNode, length: CGFloat, width: CGFloat, height: CGFloat) {
        let bagMat = SCNMaterial()
        bagMat.diffuse.contents = UIColor(white: 0.95, alpha: 1)
        bagMat.roughness.contents = 0.9
        bagMat.normal.contents = UIColor(white: 0.8, alpha: 1) 
        let strapMat = SCNMaterial()
        strapMat.diffuse.contents = UIColor(red: 0.2, green: 0.3, blue: 0.6, alpha: 1)
        let count = 10
        for _ in 0..<count {
            let isWall = Bool.random()
            let w = CGFloat.random(in: 0.5...0.8)
            let h = CGFloat.random(in: 0.4...0.6)
            let d = CGFloat.random(in: 0.4...0.6)
            let bag = SCNBox(width: w, height: h, length: d, chamferRadius: 0.05)
            bag.firstMaterial = bagMat
            let node = SCNNode(geometry: bag)
            let xPos = Float.random(in: Float(-length/2 + 2)...Float(length/2 - 2))
            if isWall {
                let isLeft = Bool.random()
                let zPos = isLeft ? Float(-width/2 + 0.5) : Float(width/2 - 0.5)
                let yPos = Float.random(in: 1.0...4.0)
                node.position = SCNVector3(xPos, yPos, zPos)
                node.eulerAngles.z = Float.random(in: -0.1...0.1)
            } else {
                let isCeil = Bool.random()
                let yPos = isCeil ? Float(height - 0.5) : 0.4
                let zPos = Float.random(in: Float(-width/2 + 1)...Float(width/2 - 1))
                node.position = SCNVector3(xPos, yPos, zPos)
            }
            let strap = SCNBox(width: w + 0.02, height: h * 0.8, length: d + 0.02, chamferRadius: 0)
            strap.firstMaterial = SCNMaterial(); strap.firstMaterial?.transparency = 0 
            for i in [-0.15, 0.15] {
                let band = SCNBox(width: 0.05, height: h + 0.01, length: d + 0.01, chamferRadius: 0)
                band.firstMaterial = strapMat
                let bn = SCNNode(geometry: band)
                bn.position.x = Float(i)
                node.addChildNode(bn)
            }
            parent.addChildNode(node)
        }
    }
    func buildScienceLab(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "ScienceLabRoom"; room.position = pos
        let w: CGFloat = 9, d: CGFloat = 8, h: CGFloat = 4
        let floorGeom = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); floorGeom.firstMaterial = floorMat
        let floorN = SCNNode(geometry: floorGeom); floorN.position = SCNVector3(0, 0, Float(d/2))
        floorN.physicsBody = .static(); floorN.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(floorN)
        let ceilGeom = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); ceilGeom.firstMaterial = ceilingPadMat
        let ceilN = SCNNode(geometry: ceilGeom); ceilN.position = SCNVector3(0, Float(h), Float(d/2))
        ceilN.physicsBody = .static(); ceilN.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(ceilN)
        for side: Float in [-1, 1] {
            let sideWall = SCNBox(width: 0.15, height: h, length: d, chamferRadius: 0); sideWall.firstMaterial = wallMat
            let swN = SCNNode(geometry: sideWall); swN.position = SCNVector3(side * Float(w/2), Float(h/2), Float(d/2))
            swN.physicsBody = .static(); swN.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(swN)
        }
        let backWall = SCNBox(width: w, height: h, length: 0.15, chamferRadius: 0); backWall.firstMaterial = wallMat
        let bwN = SCNNode(geometry: backWall); bwN.position = SCNVector3(0, Float(h/2), Float(d))
        bwN.physicsBody = .static(); bwN.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(bwN)
        let metalMat = SCNMaterial()
        metalMat.diffuse.contents = UIColor(white: 0.72, alpha: 1)
        metalMat.metalness.contents = 0.9; metalMat.roughness.contents = 0.2
        let darkMetalMat = SCNMaterial()
        darkMetalMat.diffuse.contents = UIColor(white: 0.25, alpha: 1)
        darkMetalMat.metalness.contents = 0.95
        let yellowMat = SCNMaterial()
        yellowMat.diffuse.contents = UIColor(red: 0.95, green: 0.75, blue: 0.10, alpha: 1)
        let glassMat = SCNMaterial()
        glassMat.diffuse.contents = UIColor(red: 0.75, green: 0.90, blue: 1.0, alpha: 0.25)
        glassMat.transparency = 0.65; glassMat.isDoubleSided = true
        let blueMat2 = SCNMaterial()
        blueMat2.diffuse.contents = UIColor(red: 0.15, green: 0.35, blue: 0.90, alpha: 1)
        let screenMat = SCNMaterial()
        screenMat.diffuse.contents = UIColor(red: 0.05, green: 0.35, blue: 0.18, alpha: 1)
        screenMat.emission.contents  = UIColor(red: 0.04, green: 0.30, blue: 0.15, alpha: 1)
        let whitePanelMat = SCNMaterial()
        whitePanelMat.diffuse.contents = UIColor(white: 0.88, alpha: 1)
        let freezerBlue = SCNMaterial()
        freezerBlue.diffuse.contents = UIColor(red: 0.12, green: 0.20, blue: 0.55, alpha: 1)
        freezerBlue.metalness.contents = 0.6
        let warnOrange = SCNMaterial()
        warnOrange.diffuse.contents = UIColor(red: 1.0, green: 0.40, blue: 0.05, alpha: 1)
        let slOpeningW: CGFloat = 3.0
        let slSegW = (w - slOpeningW) / 2.0
        for side: CGFloat in [-1, 1] {
            let fw = SCNBox(width: slSegW, height: h, length: 0.15, chamferRadius: 0)
            fw.firstMaterial = wallMat
            let fwn = SCNNode(geometry: fw)
            fwn.position = SCNVector3(Float(side * (slOpeningW / 2.0 + slSegW / 2.0)), Float(h / 2), 0)
            fwn.physicsBody = .static(); fwn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            room.addChildNode(fwn)
            let rail = SCNCylinder(radius: 0.016, height: slSegW)
            rail.firstMaterial = blueMat
            let rn = SCNNode(geometry: rail); rn.eulerAngles.z = .pi / 2
            rn.position = SCNVector3(Float(side * (slOpeningW / 2.0 + slSegW / 2.0)), 1.6, 0.15)
            room.addChildNode(rn)
        }
        let slPassH: CGFloat = 3.5
        let slHeaderH = h - slPassH
        let slHeader = SCNBox(width: slOpeningW, height: slHeaderH, length: 0.15, chamferRadius: 0)
        slHeader.firstMaterial = wallMat
        let slHn = SCNNode(geometry: slHeader)
        slHn.position = SCNVector3(0, Float(slPassH + slHeaderH / 2), 0)
        slHn.physicsBody = .static(); slHn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        room.addChildNode(slHn)
        let msg = SCNNode(); msg.position = SCNVector3(Float(-w/2) + 0.95, 0, 3.2)
        let msgBody = SCNBox(width: 1.4, height: 2.8, length: 0.9, chamferRadius: 0.06)
        msgBody.firstMaterial = whitePanelMat
        let msgN = SCNNode(geometry: msgBody); msgN.position = SCNVector3(0, 1.4, 0)
        msg.addChildNode(msgN); addStaticPhysics(to: msgN)
        let msgWin = SCNBox(width: 0.95, height: 0.65, length: 0.04, chamferRadius: 0.02)
        msgWin.firstMaterial = glassMat
        let msgWinN = SCNNode(geometry: msgWin); msgWinN.position = SCNVector3(0, 1.6, -0.47)
        msg.addChildNode(msgWinN)
        for (fw2, fh2, fx, fy) in [
            (Float(1.0), Float(0.04), Float(0), Float(1.93)),
            (Float(1.0), Float(0.04), Float(0), Float(1.27)),
            (Float(0.04), Float(0.66), Float(-0.49), Float(1.6)),
            (Float(0.04), Float(0.66), Float(0.49), Float(1.6))
        ] {
            let fr = SCNBox(width: CGFloat(fw2), height: CGFloat(fh2), length: 0.05, chamferRadius: 0)
            fr.firstMaterial = metalMat
            let frN = SCNNode(geometry: fr); frN.position = SCNVector3(fx, fy, -0.45)
            msg.addChildNode(frN)
        }
        for gx: Float in [-0.28, 0.28] {
            let gp = SCNTorus(ringRadius: 0.11, pipeRadius: 0.035); gp.firstMaterial = darkMetalMat
            let gpn = SCNNode(geometry: gp); gpn.eulerAngles.x = .pi/2
            gpn.position = SCNVector3(gx, 1.1, -0.47); msg.addChildNode(gpn)
        }
        let ledColors: [UIColor] = [.green, .green, UIColor(red:1,green:0.6,blue:0,alpha:1), .red]
        for (li, lc) in ledColors.enumerated() {
            let led = SCNSphere(radius: 0.025); let lm = SCNMaterial(); lm.diffuse.contents = lc; lm.emission.contents = lc
            led.firstMaterial = lm
            let ln = SCNNode(geometry: led); ln.position = SCNVector3(Float(li) * 0.07 - 0.11, 2.62, -0.46)
            msg.addChildNode(ln)
        }
        for (ci, cPos) in [(Float(-0.2), Float(0.0)), (Float(0.15), Float(-0.18)), (Float(0.0), Float(0.2))].enumerated() {
            _ = ci
            let can = SCNCylinder(radius: 0.09, height: 0.3); can.firstMaterial = metalMat
            let cN = SCNNode(geometry: can); cN.eulerAngles.z = .pi/2; cN.position = SCNVector3(cPos.0, 1.55, 0.1)
            msg.addChildNode(cN)
        }
        let hz = SCNBox(width: 0.35, height: 0.12, length: 0.02, chamferRadius: 0.01); hz.firstMaterial = yellowMat
        let hzN = SCNNode(geometry: hz); hzN.position = SCNVector3(0.45, 0.25, -0.46); msg.addChildNode(hzN)
        let msgLight = SCNLight(); msgLight.type = .omni; msgLight.color = UIColor.green; msgLight.intensity = 80
        msgLight.attenuationStartDistance = 0.2; msgLight.attenuationEndDistance = 1.5
        let msgLN = SCNNode(); msgLN.light = msgLight; msgLN.position = SCNVector3(0, 1.6, 0.1); msg.addChildNode(msgLN)
        room.addChildNode(msg)
        let melfi = SCNNode(); melfi.position = SCNVector3(Float(w/2) - 0.75, 0, 5.0)
        let melfiBody = SCNBox(width: 1.2, height: 3.0, length: 0.9, chamferRadius: 0.05)
        melfiBody.firstMaterial = freezerBlue
        let melfiN = SCNNode(geometry: melfiBody); melfiN.position = SCNVector3(0, 1.5, 0)
        melfi.addChildNode(melfiN); addStaticPhysics(to: melfiN)
        for iy in [Float(0.6), Float(1.2), Float(1.8), Float(2.4)] {
            let door = SCNBox(width: 1.15, height: 0.52, length: 0.05, chamferRadius: 0.02)
            door.firstMaterial = whitePanelMat
            let dn = SCNNode(geometry: door); dn.position = SCNVector3(0, iy, -0.47)
            melfi.addChildNode(dn)
            let handle = SCNCylinder(radius: 0.015, height: 0.5); handle.firstMaterial = metalMat
            let hn = SCNNode(geometry: handle); hn.eulerAngles.z = .pi/2; hn.position = SCNVector3(0, iy, -0.52)
            melfi.addChildNode(hn)
        }
        let tempDisp = SCNBox(width: 0.35, height: 0.14, length: 0.02, chamferRadius: 0.01)
        let dispMat = SCNMaterial(); dispMat.diffuse.contents = UIColor(red:0,green:0.5,blue:1,alpha:1)
        dispMat.emission.contents = UIColor(red:0,green:0.4,blue:0.9,alpha:1)
        tempDisp.firstMaterial = dispMat
        let tdN = SCNNode(geometry: tempDisp); tdN.position = SCNVector3(0, 2.75, -0.46)
        melfi.addChildNode(tdN)
        for iy2: Float in [0.0, 3.0] {
            let stripe = SCNBox(width: 1.25, height: 0.08, length: 0.92, chamferRadius: 0); stripe.firstMaterial = warnOrange
            let sn = SCNNode(geometry: stripe); sn.position = SCNVector3(0, iy2, 0); melfi.addChildNode(sn)
        }
        room.addChildNode(melfi)
        let hrf = SCNNode(); hrf.position = SCNVector3(Float(w/2) - 0.75, 0, 2.0)
        let hrfBody = SCNBox(width: 1.2, height: 3.0, length: 0.85, chamferRadius: 0.04)
        hrfBody.firstMaterial = whitePanelMat
        let hrfN = SCNNode(geometry: hrfBody); hrfN.position = SCNVector3(0, 1.5, 0)
        hrf.addChildNode(hrfN); addStaticPhysics(to: hrfN)
        let lapBase = SCNBox(width: 0.45, height: 0.03, length: 0.35, chamferRadius: 0.02); lapBase.firstMaterial = darkMetalMat
        let lapN = SCNNode(geometry: lapBase); lapN.position = SCNVector3(0, 3.05, -0.3); hrf.addChildNode(lapN)
        let lapScr = SCNBox(width: 0.42, height: 0.28, length: 0.02, chamferRadius: 0.01); lapScr.firstMaterial = screenMat
        let lsN = SCNNode(geometry: lapScr); lsN.position = SCNVector3(0, 3.19, -0.11); lsN.eulerAngles.x = -.pi/6
        hrf.addChildNode(lsN)
        let probe = SCNCylinder(radius: 0.03, height: 0.28); probe.firstMaterial = darkMetalMat
        let pN = SCNNode(geometry: probe); pN.position = SCNVector3(0.38, 2.5, -0.38); hrf.addChildNode(pN)
        let hrfLabel = SCNBox(width: 0.6, height: 0.1, length: 0.02, chamferRadius: 0.01); hrfLabel.firstMaterial = blueMat2
        let hlN = SCNNode(geometry: hrfLabel); hlN.position = SCNVector3(0, 2.2, -0.43); hrf.addChildNode(hlN)
        for (li2, lc2) in [UIColor.green, UIColor(red:1,green:0.6,blue:0,alpha:1)].enumerated() {
            let led2 = SCNSphere(radius: 0.022); let lm2 = SCNMaterial(); lm2.diffuse.contents = lc2; lm2.emission.contents = lc2
            led2.firstMaterial = lm2
            let ln2 = SCNNode(geometry: led2); ln2.position = SCNVector3(Float(li2) * 0.07 - 0.03, 2.9, -0.43); hrf.addChildNode(ln2)
        }
        for iy3 in [Float(0.55), Float(1.1), Float(1.65)] {
            let drawer = SCNBox(width: 1.1, height: 0.45, length: 0.04, chamferRadius: 0.01); drawer.firstMaterial = metalMat
            let drN = SCNNode(geometry: drawer); drN.position = SCNVector3(0, iy3, -0.43); hrf.addChildNode(drN)
            let dh = SCNCylinder(radius: 0.012, height: 0.45); dh.firstMaterial = darkMetalMat
            let dhN = SCNNode(geometry: dh); dhN.eulerAngles.z = .pi/2; dhN.position = SCNVector3(0, iy3, -0.47)
            hrf.addChildNode(dhN)
        }
        room.addChildNode(hrf)
        let vegNode = SCNNode(); vegNode.position = SCNVector3(1.5, 0.85, 5.8)
        let trayMat = SCNMaterial(); trayMat.diffuse.contents = UIColor(white: 0.15, alpha: 1); trayMat.metalness.contents = 0.5
        let tray = SCNBox(width: 2.8, height: 0.06, length: 0.95, chamferRadius: 0.02); tray.firstMaterial = trayMat
        let trayN = SCNNode(geometry: tray); vegNode.addChildNode(trayN); addStaticPhysics(to: trayN)
        let plantColors: [UIColor] = [
            UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1),
            UIColor(red: 0.2, green: 0.62, blue: 0.15, alpha: 1),
            UIColor(red: 0.15, green: 0.55, blue: 0.2, alpha: 1),
            UIColor(red: 0.12, green: 0.48, blue: 0.12, alpha: 1)
        ]
        for (bi, bx) in [-0.95, -0.32, 0.32, 0.95].enumerated() {
            let bag = SCNBox(width: 0.52, height: 0.06, length: 0.72, chamferRadius: 0.02)
            bag.firstMaterial = trayMat
            let bagN = SCNNode(geometry: bag); bagN.position = SCNVector3(Float(bx), 0.07, 0)
            vegNode.addChildNode(bagN)
            let pm = SCNMaterial(); pm.diffuse.contents = plantColors[bi % 4]; pm.emission.contents = UIColor(red:0,green:0.12,blue:0,alpha:1)
            for (leaf, lOff) in [(Float(0), Float(0)), (Float(-0.08), Float(0.06)), (Float(0.08), Float(0.06))] {
                let lSph = SCNSphere(radius: 0.085); lSph.firstMaterial = pm
                let lN = SCNNode(geometry: lSph); lN.position = SCNVector3(Float(bx) + leaf, 0.26 + lOff, 0)
                vegNode.addChildNode(lN)
            }
        }
        let growLightMat = SCNMaterial()
        growLightMat.diffuse.contents = UIColor(red: 1.0, green: 0.3, blue: 0.85, alpha: 1)
        growLightMat.emission.contents = UIColor(red: 1.0, green: 0.25, blue: 0.80, alpha: 1)
        let growPanel = SCNBox(width: 2.85, height: 0.05, length: 1.0, chamferRadius: 0.01)
        growPanel.firstMaterial = growLightMat
        let growN = SCNNode(geometry: growPanel); growN.position = SCNVector3(0, 0.8, 0)
        vegNode.addChildNode(growN)
        let pLight = SCNLight(); pLight.type = .omni
        pLight.color = UIColor(red:1.0, green:0.3, blue:0.9, alpha:1); pLight.intensity = 250
        pLight.attenuationStartDistance = 0.3; pLight.attenuationEndDistance = 2.0
        let plN = SCNNode(); plN.light = pLight; plN.position = SCNVector3(0, 0.7, 0)
        plN.name = "ScienceLabPlantLight"; vegNode.addChildNode(plN)
        room.addChildNode(vegNode)
        let centNode = SCNNode(); centNode.position = SCNVector3(Float(-w/2) + 0.85, 2.4, Float(d) - 0.2)
        let outerRim = SCNTorus(ringRadius: 0.72, pipeRadius: 0.09); outerRim.firstMaterial = metalMat
        let rimN = SCNNode(geometry: outerRim); rimN.eulerAngles.x = .pi/2; centNode.addChildNode(rimN)
        addStaticPhysics(to: rimN)
        let centGlass = SCNCylinder(radius: 0.69, height: 0.05); centGlass.firstMaterial = glassMat
        let cgN = SCNNode(geometry: centGlass); cgN.eulerAngles.x = .pi/2; centNode.addChildNode(cgN)
        for i in 0..<6 {
            let angle = Float(i) * .pi * 2 / 6
            let vialMat = SCNMaterial(); vialMat.diffuse.contents = UIColor(hue: CGFloat(i)/6.0, saturation: 0.6, brightness: 0.8, alpha: 1)
            vialMat.metalness.contents = 0.7
            let disc = SCNCylinder(radius: 0.08, height: 0.35); disc.firstMaterial = vialMat
            let dN = SCNNode(geometry: disc); dN.eulerAngles.z = .pi/2
            dN.position = SCNVector3(cos(angle) * 0.43, sin(angle) * 0.43, 0.08); centNode.addChildNode(dN)
        }
        let hub = SCNCylinder(radius: 0.07, height: 0.55); hub.firstMaterial = darkMetalMat
        let hubN = SCNNode(geometry: hub); hubN.eulerAngles.x = .pi/2; centNode.addChildNode(hubN)
        let cLabel = SCNBox(width: 0.30, height: 0.10, length: 0.02, chamferRadius: 0.01); cLabel.firstMaterial = yellowMat
        let clN = SCNNode(geometry: cLabel); clN.position = SCNVector3(0.0, -0.83, 0); centNode.addChildNode(clN)
        room.addChildNode(centNode)
        let incubator = SCNNode(); incubator.position = SCNVector3(1.2, 0, 5.0)
        let incBody = SCNBox(width: 0.85, height: 1.0, length: 0.75, chamferRadius: 0.04); incBody.firstMaterial = metalMat
        let incN = SCNNode(geometry: incBody); incN.position = SCNVector3(0, 0.5, 0)
        incubator.addChildNode(incN); addStaticPhysics(to: incN)
        let incDoor = SCNBox(width: 0.80, height: 0.9, length: 0.04, chamferRadius: 0.02); incDoor.firstMaterial = glassMat
        let idN = SCNNode(geometry: incDoor); idN.position = SCNVector3(0, 0.5, -0.40)
        incubator.addChildNode(idN)
        for pi2 in 0..<6 {
            let petri = SCNCylinder(radius: 0.07, height: 0.025)
            let pm2 = SCNMaterial()
            pm2.diffuse.contents = UIColor(red: 0.8, green: 1.0, blue: 0.85, alpha: 0.6)
            pm2.transparency = 0.4; petri.firstMaterial = pm2
            let pn = SCNNode(geometry: petri)
            pn.position = SCNVector3(Float(pi2 % 3) * 0.22 - 0.22, 0.22 + Float(pi2/3) * 0.22, 0.05)
            incubator.addChildNode(pn)
        }
        let incLight = SCNLight(); incLight.type = .omni; incLight.color = UIColor(red:1,green:0.9,blue:0.6,alpha:1); incLight.intensity = 60
        incLight.attenuationStartDistance = 0.1; incLight.attenuationEndDistance = 0.8
        let ilN = SCNNode(); ilN.light = incLight; ilN.position = SCNVector3(0, 0.6, 0); incubator.addChildNode(ilN)
        room.addChildNode(incubator)
        for z in stride(from: Float(0.6), through: Float(d - 0.5), by: 2.2) {
            addEquipmentRack(to: room, at: SCNVector3(Float(w/2) - 0.1, Float(h/2), z), yRotation: -.pi/2)
        }
        for z in stride(from: Float(3.5), through: Float(d - 0.5), by: 2.2) {
            addEquipmentRack(to: room, at: SCNVector3(Float(-w/2) + 0.1, Float(h/2), z), yRotation: .pi/2)
        }
        let benchMat = SCNMaterial(); benchMat.diffuse.contents = UIColor(white: 0.82, alpha: 1)
        let bench = SCNBox(width: 3.2, height: 0.07, length: 1.0, chamferRadius: 0.02); bench.firstMaterial = benchMat
        let benchN = SCNNode(geometry: bench); benchN.position = SCNVector3(2.2, 1.05, 2.2)
        addStaticPhysics(to: benchN); room.addChildNode(benchN)
        for cx: Float in [1.4, 3.0] {
            let chair = buildChair()
            chair.position = SCNVector3(cx, 0.58, 2.8)  
            chair.eulerAngles.y = 0  
            room.addChildNode(chair)
        }
        for lx: Float in [1.4, 3.0] {
            let lb = SCNBox(width: 0.38, height: 0.025, length: 0.30, chamferRadius: 0.01); lb.firstMaterial = darkMetalMat
            let lbN = SCNNode(geometry: lb); lbN.position = SCNVector3(lx, 1.09, 2.2); room.addChildNode(lbN)
            let ls2 = SCNBox(width: 0.36, height: 0.25, length: 0.02, chamferRadius: 0.01); ls2.firstMaterial = screenMat
            let ls2N = SCNNode(geometry: ls2); ls2N.position = SCNVector3(lx, 1.22, 2.05); ls2N.eulerAngles.x = -.pi/6
            room.addChildNode(ls2N)
        }
        let cableColors: [UIColor] = [UIColor(red:0.15,green:0.35,blue:0.9,alpha:1), .white, .orange, UIColor(white:0.5,alpha:1), UIColor(red:1,green:0.8,blue:0,alpha:1)]
        for (ti, tColor) in cableColors.enumerated() {
            let cM = SCNMaterial(); cM.diffuse.contents = tColor
            let cable = SCNCylinder(radius: 0.016, height: d); cable.firstMaterial = cM
            let cN = SCNNode(geometry: cable); cN.eulerAngles.z = .pi/2
            cN.position = SCNVector3(Float(ti) * 0.06 - 0.12, Float(h) - 0.12, Float(d/2))
            room.addChildNode(cN)
        }
        let winFrame = SCNBox(width: 1.0, height: 1.0, length: 0.1, chamferRadius: 0.05); winFrame.firstMaterial = metalMat
        let wfN = SCNNode(geometry: winFrame); wfN.position = SCNVector3(2.5, 2.5, Float(d) - 0.02)
        room.addChildNode(wfN)
        let winGlass = SCNBox(width: 0.8, height: 0.8, length: 0.06, chamferRadius: 0.02); winGlass.firstMaterial = glassMat
        let wgN = SCNNode(geometry: winGlass); wgN.position = SCNVector3(2.5, 2.5, Float(d) + 0.01)
        room.addChildNode(wgN)
        addRoomTrigger(to: room, name: "ScienceLabTrigger", width: w-1, depth: d-1, height: h)
        let roomLight = SCNLight()
        roomLight.type = .omni
        roomLight.color = UIColor(red: 0.88, green: 1.0, blue: 0.92, alpha: 1)
        roomLight.intensity = 900
        roomLight.attenuationStartDistance = 2.0; roomLight.attenuationEndDistance = 12.0
        let roomLightNode = SCNNode()
        roomLightNode.name = "ScienceLabRoomLight"
        roomLightNode.light = roomLight
        roomLightNode.position = SCNVector3(0, Float(h) - 0.2, Float(d/2))
        room.addChildNode(roomLightNode)
        return room
    }
    func buildChair() -> SCNNode {
        let seatMat = SCNMaterial()
        seatMat.diffuse.contents = UIColor(white: 0.08, alpha: 1)
        seatMat.metalness.contents = 0.3; seatMat.roughness.contents = 0.7
        let chairLegMat = SCNMaterial()
        chairLegMat.diffuse.contents = UIColor(white: 0.55, alpha: 1)
        chairLegMat.metalness.contents = 0.9; chairLegMat.roughness.contents = 0.15
        let chair = SCNNode()
        let seat = SCNBox(width: 0.55, height: 0.08, length: 0.52, chamferRadius: 0.06)
        seat.firstMaterial = seatMat
        let seatN = SCNNode(geometry: seat); seatN.position = SCNVector3(0, 0, 0)
        addStaticPhysics(to: seatN)
        chair.addChildNode(seatN)
        let back = SCNBox(width: 0.52, height: 0.55, length: 0.07, chamferRadius: 0.05)
        back.firstMaterial = seatMat
        let backN = SCNNode(geometry: back); backN.position = SCNVector3(0, 0.3, 0.22)
        backN.eulerAngles.x = 0.12  
        addStaticPhysics(to: backN)
        chair.addChildNode(backN)
        let lumbar = SCNBox(width: 0.38, height: 0.15, length: 0.08, chamferRadius: 0.04)
        lumbar.firstMaterial = seatMat
        let lumbarN = SCNNode(geometry: lumbar); lumbarN.position = SCNVector3(0, 0.06, 0.24)
        chair.addChildNode(lumbarN)
        for axOff: Float in [-0.25, 0.25] {
            let arm = SCNBox(width: 0.06, height: 0.04, length: 0.35, chamferRadius: 0.02)
            arm.firstMaterial = chairLegMat
            let armN2 = SCNNode(geometry: arm); armN2.position = SCNVector3(axOff, 0.14, 0.02)
            chair.addChildNode(armN2)
            let upright = SCNBox(width: 0.04, height: 0.14, length: 0.04, chamferRadius: 0.01)
            upright.firstMaterial = chairLegMat
            let uprightN = SCNNode(geometry: upright); uprightN.position = SCNVector3(axOff, 0.07, 0.18)
            chair.addChildNode(uprightN)
        }
        let col = SCNCylinder(radius: 0.035, height: 0.52)
        col.firstMaterial = chairLegMat
        let colN = SCNNode(geometry: col); colN.position = SCNVector3(0, -0.3, 0)
        chair.addChildNode(colN)
        for si in 0..<5 {
            let ang = Float(si) * .pi * 2.0 / 5.0
            let spoke = SCNCylinder(radius: 0.018, height: 0.42)
            spoke.firstMaterial = chairLegMat
            let spN = SCNNode(geometry: spoke)
            spN.eulerAngles.z = .pi / 2
            spN.eulerAngles.y = ang
            spN.position = SCNVector3(cos(ang) * 0.2, -0.54, sin(ang) * 0.2)
            chair.addChildNode(spN)
            let caster = SCNCylinder(radius: 0.028, height: 0.04)
            caster.firstMaterial = seatMat
            let castN = SCNNode(geometry: caster)
            castN.eulerAngles.z = .pi / 2
            castN.position = SCNVector3(cos(ang) * 0.4, -0.56, sin(ang) * 0.4)
            chair.addChildNode(castN)
        }
        return chair
    }
    func buildCommandControl(at pos: SCNVector3) -> SCNNode {
        let room = SCNNode(); room.name = "CommandControlRoom"; room.position = pos
        let w: CGFloat = 9, d: CGFloat = 8, h: CGFloat = 4
        let floor = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); floor.firstMaterial = floorMat
        let fn = SCNNode(geometry: floor); fn.position = SCNVector3(0, 0, Float(d/2))
        fn.physicsBody = .static(); fn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(fn)
        let ceil = SCNBox(width: w, height: 0.15, length: d, chamferRadius: 0); ceil.firstMaterial = ceilingPadMat
        let cn = SCNNode(geometry: ceil); cn.position = SCNVector3(0, Float(h), Float(d/2))
        cn.physicsBody = .static(); cn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(cn)
        for side: Float in [-1, 1] {
            let wall = SCNBox(width: 0.15, height: h, length: d, chamferRadius: 0); wall.firstMaterial = wallMat
            let wn = SCNNode(geometry: wall); wn.position = SCNVector3(side * Float(w/2), Float(h/2), Float(d/2))
            wn.physicsBody = .static(); wn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(wn)
        }
        let bWall = SCNBox(width: w, height: h, length: 0.15, chamferRadius: 0); bWall.firstMaterial = wallMat
        let bwn = SCNNode(geometry: bWall); bwn.position = SCNVector3(0, Float(h/2), Float(d))
        bwn.physicsBody = .static(); bwn.physicsBody?.categoryBitMask = PhysicsCategory.wall; room.addChildNode(bwn)
        let ccOpeningW: CGFloat = 3.0
        let ccSegW = (w - ccOpeningW) / 2.0
        for ccSide: CGFloat in [-1, 1] {
            let ccFw = SCNBox(width: ccSegW, height: h, length: 0.15, chamferRadius: 0)
            ccFw.firstMaterial = wallMat
            let ccFwn = SCNNode(geometry: ccFw)
            ccFwn.position = SCNVector3(Float(ccSide * (ccOpeningW / 2.0 + ccSegW / 2.0)), Float(h / 2), 0)
            ccFwn.physicsBody = .static(); ccFwn.physicsBody?.categoryBitMask = PhysicsCategory.wall
            room.addChildNode(ccFwn)
        }
        let ccPassH: CGFloat = 3.5
        let ccHeaderH = h - ccPassH
        let ccHeader = SCNBox(width: ccOpeningW, height: ccHeaderH, length: 0.15, chamferRadius: 0)
        ccHeader.firstMaterial = wallMat
        let ccHn = SCNNode(geometry: ccHeader)
        ccHn.position = SCNVector3(0, Float(ccPassH + ccHeaderH / 2), 0)
        ccHn.physicsBody = .static(); ccHn.physicsBody?.categoryBitMask = PhysicsCategory.wall
        room.addChildNode(ccHn)
        let consoleMat = SCNMaterial(); consoleMat.diffuse.contents = UIColor(white: 0.18, alpha: 1); consoleMat.metalness.contents = 0.7
        let screenOffMat = SCNMaterial(); screenOffMat.diffuse.contents = UIColor(white: 0.05, alpha: 1)
        let screenBlueMat = SCNMaterial()
        screenBlueMat.diffuse.contents = UIColor(red: 0.02, green: 0.05, blue: 0.2, alpha: 1)
        screenBlueMat.emission.contents = UIColor(red: 0.0, green: 0.12, blue: 0.55, alpha: 1)
        let screenGreenMat = SCNMaterial()
        screenGreenMat.diffuse.contents = UIColor(red: 0.0, green: 0.12, blue: 0.04, alpha: 1)
        screenGreenMat.emission.contents = UIColor(red: 0.0, green: 0.5, blue: 0.2, alpha: 1)
        let kbMat = SCNMaterial(); kbMat.diffuse.contents = UIColor(white: 0.12, alpha: 1); kbMat.metalness.contents = 0.5
        let btnGreenMat = SCNMaterial(); btnGreenMat.diffuse.contents = UIColor.green; btnGreenMat.emission.contents = UIColor.green
        let btnYellowMat = SCNMaterial(); btnYellowMat.diffuse.contents = UIColor.yellow; btnYellowMat.emission.contents = UIColor.yellow
        let cableMat = SCNMaterial(); cableMat.diffuse.contents = UIColor(white: 0.3, alpha: 1)
        let metalMat = SCNMaterial(); metalMat.diffuse.contents = UIColor(white: 0.6, alpha: 1); metalMat.metalness.contents = 0.9
        let darkMetalMat = SCNMaterial(); darkMetalMat.diffuse.contents = UIColor(white: 0.25, alpha: 1); darkMetalMat.metalness.contents = 0.9
        let scrMats: [SCNMaterial] = [screenBlueMat, screenGreenMat, screenBlueMat, screenOffMat,
                                       screenGreenMat, screenBlueMat, screenOffMat, screenGreenMat]
        let bezzelMat = SCNMaterial(); bezzelMat.diffuse.contents = UIColor(white: 0.08, alpha: 1)
        for row in 0..<2 {
            for col in 0..<4 {
                let idx = row * 4 + col
                let sx = Float(col) * 2.0 - 3.0
                let sy = Float(row) * 1.2 + 1.5
                let bezel = SCNBox(width: 1.85, height: 1.05, length: 0.04, chamferRadius: 0.02)
                bezel.firstMaterial = bezzelMat
                let bzN = SCNNode(geometry: bezel); bzN.position = SCNVector3(sx, sy, Float(d) - 0.12)
                room.addChildNode(bzN)
                let scr = SCNPlane(width: 1.7, height: 0.95); scr.firstMaterial = scrMats[idx % scrMats.count]
                let scrN = SCNNode(geometry: scr); scrN.position = SCNVector3(sx, sy, Float(d) - 0.09)
                room.addChildNode(scrN)
                if idx % 2 == 0 {
                    for li in 0..<5 {
                        let lMat = SCNMaterial()
                        lMat.diffuse.contents = UIColor(red: 0.3, green: 1.0, blue: 0.5, alpha: 0.6)
                        lMat.emission.contents = UIColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 0.6)
                        let line = SCNPlane(width: 1.4, height: 0.03); line.firstMaterial = lMat
                        let lN = SCNNode(geometry: line)
                        lN.position = SCNVector3(sx, sy + 0.3 - Float(li)*0.15, Float(d) - 0.08)
                        room.addChildNode(lN)
                    }
                }
            }
        }
        let wallGlow = SCNLight(); wallGlow.type = .omni
        wallGlow.color = UIColor(red: 0.1, green: 0.2, blue: 0.6, alpha: 1); wallGlow.intensity = 250
        wallGlow.attenuationStartDistance = 1; wallGlow.attenuationEndDistance = 6
        let wgN = SCNNode(); wgN.light = wallGlow; wgN.position = SCNVector3(0, 2.0, Float(d) - 0.5)
        room.addChildNode(wgN)
        let kbPanel = SCNBox(width: 8.0, height: 0.35, length: 0.25, chamferRadius: 0.02)
        kbPanel.firstMaterial = consoleMat
        let kbn = SCNNode(geometry: kbPanel); kbn.position = SCNVector3(0, 0.9, Float(d) - 0.18)
        addStaticPhysics(to: kbn); room.addChildNode(kbn)
        for col in 0..<20 {
            let bMat = col % 4 == 0 ? btnGreenMat : (col % 7 == 0 ? btnYellowMat : kbMat)
            let btn = SCNBox(width: 0.1, height: 0.1, length: 0.02, chamferRadius: 0.01); btn.firstMaterial = bMat
            let bN = SCNNode(geometry: btn)
            bN.position = SCNVector3(Float(col) * 0.38 - 3.6, 0.9, Float(d) - 0.07)
            room.addChildNode(bN)
        }
        let centreBase = SCNBox(width: 5.5, height: 0.7, length: 2.0, chamferRadius: 0.08)
        centreBase.firstMaterial = consoleMat
        let cbN = SCNNode(geometry: centreBase); cbN.position = SCNVector3(0, 0.35, 5.5)
        addStaticPhysics(to: cbN); room.addChildNode(cbN)
        let ctrlTop = SCNBox(width: 5.5, height: 0.05, length: 2.1, chamferRadius: 0.04)
        ctrlTop.firstMaterial = kbMat
        let ctN = SCNNode(geometry: ctrlTop); ctN.position = SCNVector3(0, 0.72, 5.5)
        ctN.eulerAngles.x = -0.25  
        room.addChildNode(ctN)
        let laptopScreenMats: [SCNMaterial] = [screenBlueMat, screenGreenMat, screenBlueMat]
        for (li, lx) in [-1.8, 0.0, 1.8].enumerated() {
            let lid = SCNBox(width: 1.0, height: 0.7, length: 0.04, chamferRadius: 0.03)
            lid.firstMaterial = consoleMat
            let lidN = SCNNode(geometry: lid)
            lidN.position = SCNVector3(Float(lx), 1.4, 5.2)
            lidN.eulerAngles.x = 0.5   
            room.addChildNode(lidN)
            let ls = SCNPlane(width: 0.9, height: 0.6); ls.firstMaterial = laptopScreenMats[li]
            let lsN = SCNNode(geometry: ls)
            lsN.position = SCNVector3(Float(lx), 1.4, 5.22)
            lsN.eulerAngles.x = 0.5
            room.addChildNode(lsN)
            let kb = SCNBox(width: 1.0, height: 0.03, length: 0.65, chamferRadius: 0.02); kb.firstMaterial = kbMat
            let kbN2 = SCNNode(geometry: kb); kbN2.position = SCNVector3(Float(lx), 0.75, 4.9)
            room.addChildNode(kbN2)
        }
        let stickBase = SCNCylinder(radius: 0.12, height: 0.08); stickBase.firstMaterial = darkMetalMat
        let sbN = SCNNode(geometry: stickBase); sbN.position = SCNVector3(2.4, 0.78, 4.8)
        room.addChildNode(sbN)
        let stick = SCNCylinder(radius: 0.035, height: 0.3); stick.firstMaterial = darkMetalMat
        let stN = SCNNode(geometry: stick); stN.eulerAngles.x = -0.4
        stN.position = SCNVector3(2.4, 1.0, 4.65); room.addChildNode(stN)
        let dialPositions: [(Float, Float)] = [(-2.4, 5.3), (-2.1, 5.7)]
        for (di, dp) in dialPositions.enumerated() {
            let dial = SCNCylinder(radius: 0.07, height: 0.04); dial.firstMaterial = darkMetalMat
            let dn = SCNNode(geometry: dial); dn.eulerAngles.x = .pi/2
            dn.position = SCNVector3(dp.0, 0.78, dp.1 + Float(di)*0.05)
            room.addChildNode(dn)
        }
        for cx: Float in [-1.8, 0.0, 1.8] {
            let chair = buildChair()
            chair.position = SCNVector3(cx, 0.58, 3.8)  
            chair.eulerAngles.y = Float.pi  
            room.addChildNode(chair)
        }
        for z in stride(from: Float(1.5), through: Float(d - 1.0), by: 2.8) {
            addEquipmentRack(to: room, at: SCNVector3(Float(w/2) - 0.1, Float(h/2), z), yRotation: -.pi/2)
        }
        addEquipmentRack(to: room, at: SCNVector3(Float(-w/2) + 0.1, Float(h/2), 4.5), yRotation: .pi/2)
        addEquipmentRack(to: room, at: SCNVector3(Float(-w/2) + 0.1, Float(h/2), 6.5), yRotation: .pi/2)
        let tubeColors: [UIColor] = [
            UIColor(red:0.15,green:0.35,blue:0.9,alpha:1), .white, .orange,
            UIColor(white:0.5,alpha:1), .yellow, UIColor(red:0.8,green:0.1,blue:0.1,alpha:1)
        ]
        for (ti, tColor) in tubeColors.enumerated() {
            let cM = SCNMaterial(); cM.diffuse.contents = tColor
            let cable = SCNCylinder(radius: 0.015, height: CGFloat(d)); cable.firstMaterial = cM
            let cN = SCNNode(geometry: cable); cN.eulerAngles.z = .pi/2
            cN.position = SCNVector3(Float(ti) * 0.1 - 0.25, Float(h) - 0.1, Float(d/2)); room.addChildNode(cN)
        }
        for (bi, (bx, bz)) in [(-3.0, 2.5), (0.0, 1.5), (2.5, 3.5), (-1.5, 5.0), (1.5, 5.5)].enumerated() {
            let boxMat = SCNMaterial(); boxMat.diffuse.contents = UIColor(white: 0.12, alpha: 1); boxMat.metalness.contents = 0.5
            let box = SCNBox(width: 0.8, height: 0.25, length: 0.6, chamferRadius: 0.02); box.firstMaterial = boxMat
            let boxN = SCNNode(geometry: box); boxN.position = SCNVector3(Float(bx), Float(h) - 0.21, Float(bz))
            room.addChildNode(boxN)
            let lMat = SCNMaterial(); lMat.diffuse.contents = UIColor.cyan; lMat.emission.contents = UIColor.cyan
            let led = SCNBox(width: 0.5, height: 0.02, length: 0.04, chamferRadius: 0); led.firstMaterial = lMat
            let ledN = SCNNode(geometry: led); ledN.position = SCNVector3(Float(bx), Float(h) - 0.36, Float(bz))
            room.addChildNode(ledN); _ = bi
        }
        let ovhdMat = SCNMaterial()
        ovhdMat.diffuse.contents = UIColor(red: 0.0, green: 0.06, blue: 0.22, alpha: 1)
        ovhdMat.emission.contents = UIColor(red: 0.0, green: 0.08, blue: 0.4, alpha: 1)
        for (oi, ox) in [-1.5, 0.5].enumerated() {
            let ovScr = SCNPlane(width: 0.9, height: 0.65); ovScr.firstMaterial = ovhdMat
            let ovN = SCNNode(geometry: ovScr)
            ovN.position = SCNVector3(Float(ox), Float(h) - 0.5, Float(d/2) + Float(oi)*0.3)
            ovN.eulerAngles.x = -.pi/3   
            room.addChildNode(ovN)
            let ovFrame = SCNBox(width: 0.95, height: 0.7, length: 0.04, chamferRadius: 0.02)
            let ofMat = SCNMaterial(); ofMat.diffuse.contents = UIColor(white: 0.1, alpha: 1)
            ovFrame.firstMaterial = ofMat
            let ofN = SCNNode(geometry: ovFrame)
            ofN.position = SCNVector3(Float(ox), Float(h) - 0.5, Float(d/2) + Float(oi)*0.3)
            ofN.eulerAngles.x = -.pi/3
            room.addChildNode(ofN)
        }
        let arm = SCNCylinder(radius: 0.02, height: 0.35); arm.firstMaterial = metalMat
        let armN = SCNNode(geometry: arm); armN.position = SCNVector3(-0.5, Float(h) - 0.32, Float(d/2))
        room.addChildNode(armN)
        let ctrlLight = SCNLight(); ctrlLight.type = .omni
        ctrlLight.color = UIColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 1); ctrlLight.intensity = 80
        ctrlLight.attenuationStartDistance = 0.5; ctrlLight.attenuationEndDistance = 4
        let ctrlLN = SCNNode(); ctrlLN.light = ctrlLight; ctrlLN.position = SCNVector3(0, 1.2, 3.0)
        room.addChildNode(ctrlLN)
        addRoomTrigger(to: room, name: "CommandControlTrigger", width: w-1, depth: d-1, height: h)
        let roomLightPositions: [(Float, Float, Float)] = [
            (0,    Float(h) - 0.3, 1.0),   
            (0,    Float(h) - 0.3, 4.0),   
            (0,    Float(h) - 0.3, 7.0),   
            (-2.5, Float(h) - 0.3, 2.5),   
            ( 2.5, Float(h) - 0.3, 2.5),   
            (-2.5, Float(h) - 0.3, 6.0),   
            ( 2.5, Float(h) - 0.3, 6.0)
        ]
        for lp in roomLightPositions {
            let wl = SCNLight(); wl.type = .omni
            wl.color = UIColor(white: 1.0, alpha: 1); wl.intensity = 600
            wl.attenuationStartDistance = 1; wl.attenuationEndDistance = 8
            let wln = SCNNode(); wln.light = wl
            wln.position = SCNVector3(lp.0, lp.1, lp.2)
            wln.name = "CommandControlRoomLight"
            wln.isHidden = true
            room.addChildNode(wln)
            let strip = SCNBox(width: 1.2, height: 0.03, length: 0.12, chamferRadius: 0.01)
            let sm = SCNMaterial(); sm.diffuse.contents = UIColor.white
            sm.emission.contents = UIColor(white: 0.95, alpha: 1); strip.firstMaterial = sm
            let sn = SCNNode(geometry: strip)
            sn.position = SCNVector3(lp.0, Float(h) - 0.02, lp.2)
            room.addChildNode(sn)
        }
        return room
    }
}
