import SwiftUI

struct RootView: View {
    let catalog: ContentCatalog

    var body: some View {
        // .tabItem instead of Tab: Tab needs iOS 18, the app targets 17.6.
        TabView {
            HomeView(catalog: catalog)
                .tabItem { Label("Главная", systemImage: "house") }
            SettingsView()
                .tabItem { Label("Настройки", systemImage: "gearshape") }
        }
    }
}

#Preview {
    RootView(catalog: ContentLoader.loadOrCrash())
}
