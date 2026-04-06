import SceneKit

struct PhysicsCategory {
    
    static let player: Int          = 1 << 0
    static let wall: Int            = 1 << 1
    static let trigger: Int         = 1 << 2
    static let floatingObject: Int  = 1 << 3
    static let npc: Int             = 1 << 4
}
