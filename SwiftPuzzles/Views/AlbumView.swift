import SwiftUI

struct AlbumView: View {
    let album: Album
    let topics: [Topic]
    let solvedTopicIDs: Set<String>
    let startedTopicIDs: Set<String>

    private let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(topics) { topic in
                    TopicTile(
                        topic: topic,
                        status: album.status(
                            of: topic.id,
                            solvedTopicIDs: solvedTopicIDs,
                            startedTopicIDs: startedTopicIDs
                        )
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
    let status: TopicStatus

    private var isColored: Bool { status == .inProgress || status == .solved }
    private var isBlurred: Bool { status != .solved }

    var body: some View {
        VStack(spacing: 10) {
            // Clear square sets the size; the image fills it and gets cropped to a square.
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(topic.imageName)
                        .resizable()
                        .scaledToFill()
                        .blur(radius: isBlurred ? 16 : 0, opaque: true)
                        .grayscale(isColored ? 0 : 1)
                }
                // overlay is a ZStack sized by the view below it, so the icon stays centered in the square.
                .overlay {
                    if status == .next {
                        Image(systemName: "play.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                }
                .clipShape(.rect(cornerRadius: 28))

            title
                .font(.subheadline)
                .foregroundStyle(status == .locked ? .secondary : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2, reservesSpace: true)
        }
    }

    private var title: Text {
        // Image inside Text wraps together with the words, unlike an HStack.
        status == .locked
            ? Text("\(Image(systemName: "lock.fill")) \(topic.title)")
            : Text(topic.title)
    }
}

#Preview("Nothing solved") {
    let catalog = ContentLoader.loadOrCrash()
    let album = catalog.albums[0]
    NavigationStack {
        AlbumView(album: album, topics: catalog.topics(in: album), solvedTopicIDs: [], startedTopicIDs: [])
    }
}

#Preview("Solved and in progress") {
    let catalog = ContentLoader.loadOrCrash()
    let album = catalog.albums[0]
    NavigationStack {
        AlbumView(
            album: album,
            topics: catalog.topics(in: album),
            solvedTopicIDs: ["optionals"],
            startedTopicIDs: ["enums"]
        )
    }
}
