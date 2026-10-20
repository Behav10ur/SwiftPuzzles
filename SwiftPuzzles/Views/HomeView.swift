import SwiftUI

struct HomeView: View {
    let catalog: ContentCatalog

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(catalog.albums) { album in
                        NavigationLink(value: album) {
                            // Solved count stays 0 until progress is stored in SwiftData (stage 5).
                            AlbumCard(album: album, solvedCount: 0)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Альбомы")
            .navigationDestination(for: Album.self) { album in
                AlbumView(album: album, topics: catalog.topics(in: album), solvedTopicIDs: [], startedTopicIDs: [])
            }
        }
    }
}

private struct AlbumCard: View {
    let album: Album
    let solvedCount: Int

    private var totalCount: Int { album.topicIDs.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(album.title)
                .font(.title2.bold())

            HStack(spacing: 12) {
                Text("\(solvedCount) / \(totalCount)")
                    .font(.subheadline.bold())
                    .monospacedDigit()
                ProgressBar(fraction: totalCount == 0 ? 0 : Double(solvedCount) / Double(totalCount))
            }
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(album.gradient.linear, in: .rect(cornerRadius: 32))
    }
}

private struct ProgressBar: View {
    let fraction: Double

    var body: some View {
        Capsule()
            .fill(.white.opacity(0.35))
            .overlay(alignment: .leading) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 12)
    }
}

#Preview {
    HomeView(catalog: ContentLoader.loadOrCrash())
}
