import Foundation

/// Mirrors content.json: albums reference topics by ID, topics live in one flat list.
struct ContentCatalog: Codable {
    let albums: [Album]
    let topics: [Topic]

    func topic(withID id: String) -> Topic? {
        topics.first { $0.id == id }
    }

    /// Topics in the album's order. Unknown IDs are skipped here; `ContentValidator` reports them.
    func topics(in album: Album) -> [Topic] {
        album.topicIDs.compactMap(topic(withID:))
    }
}
