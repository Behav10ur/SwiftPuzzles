import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Пока пусто",
                systemImage: "gearshape",
                description: Text("Здесь появится выбор сложности пазла.")
            )
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView()
}
