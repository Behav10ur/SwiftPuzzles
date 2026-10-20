import SwiftUI

struct RootView: View {
    let catalog: ContentCatalog

    var body: some View {
        TabView {
            Tab("Главная", systemImage: "house") {
                HomeView(catalog: catalog)
            }
            Tab("Настройки", systemImage: "gearshape") {
                SettingsView()
            }
        }
    }
}

#Preview {
    RootView(catalog: ContentLoader.loadOrCrash())
}
