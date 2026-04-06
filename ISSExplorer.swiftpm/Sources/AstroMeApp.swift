import SwiftUI


@main
struct AstroMeApp: App {
    var body: some Scene {
        WindowGroup {
            GameSceneView()
                .ignoresSafeArea()
                .statusBarHidden()
        }
    }
}
