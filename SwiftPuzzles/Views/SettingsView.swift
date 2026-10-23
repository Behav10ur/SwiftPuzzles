import SwiftUI

struct SettingsView: View {
    @AppStorage(Difficulty.storageKey) private var difficulty: Difficulty = .easy

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Сетка", selection: $difficulty) {
                        ForEach(Difficulty.allCases) { difficulty in
                            Text(difficulty.title).tag(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Сложность")
                } footer: {
                    Text("Новая сетка применится к следующему пазлу.")
                }
            }
            .navigationTitle("Настройки")
        }
    }
}

#Preview {
    SettingsView()
}
