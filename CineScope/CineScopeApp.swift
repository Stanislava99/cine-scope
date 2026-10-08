import SwiftUI

@main
struct CineScopeApp: App {
    @State private var dependencies = AppDependencies.makeDefault()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(dependencies)
                .environment(dependencies.favorites)
                .task {
                    await dependencies.favorites.load()
                }
        }
    }
}
