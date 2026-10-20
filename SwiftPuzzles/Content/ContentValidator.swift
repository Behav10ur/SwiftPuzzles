import Foundation

// Pure data; nonisolated so `ContentError` (which is never MainActor-bound) can print it.
nonisolated enum ContentIssue: Equatable, CustomStringConvertible {
    case duplicateAlbumID(String)
    case duplicateTopicID(String)
    case unknownTopicID(String, albumID: String)
    case topicInMultipleAlbums(String, albumIDs: [String])
    case topicNotInAnyAlbum(String)
    case missingImage(String, topicID: String)
    case errorRegionOutOfBounds(topicID: String)

    var description: String {
        switch self {
        case .duplicateAlbumID(let id):
            "album ID '\(id)' is used more than once"
        case .duplicateTopicID(let id):
            "topic ID '\(id)' is used more than once"
        case .unknownTopicID(let id, let albumID):
            "album '\(albumID)' lists topic '\(id)', which does not exist"
        case .topicInMultipleAlbums(let id, let albumIDs):
            "topic '\(id)' is listed \(albumIDs.count) times, in albums \(albumIDs)"
        case .topicNotInAnyAlbum(let id):
            "topic '\(id)' is not listed in any album"
        case .missingImage(let name, let topicID):
            "topic '\(topicID)' uses image '\(name)', which is not in the assets"
        case .errorRegionOutOfBounds(let topicID):
            "topic '\(topicID)' has an errorRegion outside 0...1"
        }
    }
}

enum ContentValidator {
    /// Collects every issue instead of stopping at the first one, so a single run shows all typos.
    static func issues(in catalog: ContentCatalog, imageExists: (String) -> Bool) -> [ContentIssue] {
        var issues: [ContentIssue] = []
        issues += duplicates(in: catalog.albums.map(\.id)).map(ContentIssue.duplicateAlbumID)
        issues += duplicates(in: catalog.topics.map(\.id)).map(ContentIssue.duplicateTopicID)

        let knownTopicIDs = Set(catalog.topics.map(\.id))
        // One entry per mention, so a topic listed twice in the same album is caught too.
        var albumIDsByTopicID: [String: [String]] = [:]
        for album in catalog.albums {
            for topicID in album.topicIDs {
                if knownTopicIDs.contains(topicID) {
                    albumIDsByTopicID[topicID, default: []].append(album.id)
                } else {
                    issues.append(.unknownTopicID(topicID, albumID: album.id))
                }
            }
        }

        for topic in catalog.topics {
            let albumIDs = albumIDsByTopicID[topic.id, default: []]
            if albumIDs.isEmpty {
                issues.append(.topicNotInAnyAlbum(topic.id))
            } else if albumIDs.count > 1 {
                issues.append(.topicInMultipleAlbums(topic.id, albumIDs: albumIDs))
            }

            for name in [topic.imageName] + topic.wrongImageNames where !imageExists(name) {
                issues.append(.missingImage(name, topicID: topic.id))
            }

            if !topic.errorRegion.isWithinUnitSquare {
                issues.append(.errorRegionOutOfBounds(topicID: topic.id))
            }
        }
        return issues
    }

    /// Each repeated ID once, in order of first repetition.
    private static func duplicates(in ids: [String]) -> [String] {
        var seen: Set<String> = []
        var reported: Set<String> = []
        return ids.filter { !seen.insert($0).inserted && reported.insert($0).inserted }
    }
}
