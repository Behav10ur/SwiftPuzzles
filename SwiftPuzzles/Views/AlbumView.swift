import SwiftUI

struct AlbumView: View {
    let album: Album
    let topics: [Topic]
    let solvedTopicIDs: Set<String>

    private let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(topics) { topic in
                    TopicTile(
                        topic: topic,
                        isUnlocked: album.isTopicUnlocked(topic.id, solvedTopicIDs: solvedTopicIDs)
                    )
                }
            }
            .padding()
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TopicTile: View {
    let topic: Topic
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Clear square sets the size; the image fills it and gets cropped to a square.
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(topic.imageName)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 16, opaque: true)
                        .grayscale(isUnlocked ? 0 : 1)
                }
                .clipShape(.rect(cornerRadius: 28))

            Text(topic.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

#Preview {
    let catalog = ContentLoader.loadOrCrash()
    let album = catalog.albums[0]
    NavigationStack {
        AlbumView(album: album, topics: catalog.topics(in: album), solvedTopicIDs: [])
    }
}
