import SwiftUI

struct HomeView: View {
    let catalog: ContentCatalog

    var body: some View {
        NavigationStack {
            List(catalog.albums) { album in
                Section {
                    ForEach(catalog.topics(in: album)) { topic in
                        Label(topic.title, systemImage: "puzzlepiece")
                    }
                } header: {
                    // Solved count stays 0 until progress is stored in SwiftData (stage 5).
                    AlbumHeader(title: album.title, solvedCount: 0, totalCount: album.topicIDs.count)
                }
            }
            .navigationTitle("Альбомы")
        }
    }
}

private struct AlbumHeader: View {
    let title: String
    let solvedCount: Int
    let totalCount: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(solvedCount) из \(totalCount)")
                .monospacedDigit()
        }
    }
}

#Preview {
    HomeView(catalog: ContentLoader.loadOrCrash())
}
