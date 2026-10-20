import Foundation
import Testing
@testable import SwiftPuzzles

// App code is MainActor-isolated by default; this target is not, so opt in explicitly.
@MainActor
struct ContentTests {

    @Test func bundledContentIsValid() throws {
        let catalog = try ContentLoader.load()
        #expect(!catalog.albums.isEmpty)
    }

    @Test func unknownTopicIDIsReported() {
        let catalog = ContentCatalog(
            albums: [.stub(id: "basics", topicIDs: ["optinals"])],
            topics: [.stub(id: "optionals")]
        )

        #expect(validate(catalog) == [
            .unknownTopicID("optinals", albumID: "basics"),
            .topicNotInAnyAlbum("optionals"),
        ])
    }

    @Test func topicInTwoAlbumsIsReported() {
        let catalog = ContentCatalog(
            albums: [
                .stub(id: "basics", topicIDs: ["optionals"]),
                .stub(id: "memory", topicIDs: ["optionals"]),
            ],
            topics: [.stub(id: "optionals")]
        )

        #expect(validate(catalog) == [
            .topicInMultipleAlbums("optionals", albumIDs: ["basics", "memory"]),
        ])
    }

    @Test func duplicateTopicIDIsReported() {
        let catalog = ContentCatalog(
            albums: [.stub(id: "basics", topicIDs: ["optionals"])],
            topics: [.stub(id: "optionals"), .stub(id: "optionals")]
        )

        #expect(validate(catalog) == [.duplicateTopicID("optionals")])
    }

    @Test func errorRegionOutOfBoundsIsReported() {
        let region = NormalizedRect(x: 0.9, y: 0, width: 0.2, height: 0.1)
        let catalog = ContentCatalog(
            albums: [.stub(id: "basics", topicIDs: ["optionals"])],
            topics: [.stub(id: "optionals", errorRegion: region)]
        )

        #expect(validate(catalog) == [.errorRegionOutOfBounds(topicID: "optionals")])
    }

    @Test func missingImageIsReported() {
        let catalog = ContentCatalog(
            albums: [.stub(id: "basics", topicIDs: ["optionals"])],
            topics: [.stub(id: "optionals")]
        )

        let issues = validate(catalog, imageExists: { $0 == "schema" })

        #expect(issues == [.missingImage("schema_broken", topicID: "optionals")])
    }

    @Test func hexColorRoundTrips() throws {
        let data = Data("\"#3F8EF7\"".utf8)
        let color = try JSONDecoder().decode(HexColor.self, from: data)

        #expect(color == HexColor(hex: "#3F8EF7"))
        #expect(try JSONEncoder().encode(color) == data)
    }

    @Test(arguments: ["3F8EF7", "#3F8EF", "#3F8EF7FF", "#GGGGGG", "#+3F8EF"])
    func invalidHexFailsToDecode(hex: String) {
        let data = Data("\"\(hex)\"".utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(HexColor.self, from: data)
        }
    }

    @Test func topicsUnlockOneByOne() {
        let album = Album.stub(id: "basics", topicIDs: ["optionals", "enums", "errors"])

        #expect(album.isTopicUnlocked("optionals", solvedTopicIDs: []))
        #expect(!album.isTopicUnlocked("enums", solvedTopicIDs: []))
        #expect(album.isTopicUnlocked("enums", solvedTopicIDs: ["optionals"]))
        #expect(!album.isTopicUnlocked("errors", solvedTopicIDs: ["optionals"]))
        #expect(!album.isTopicUnlocked("unknown", solvedTopicIDs: []))
    }

    private func validate(
        _ catalog: ContentCatalog,
        imageExists: (String) -> Bool = { _ in true }
    ) -> [ContentIssue] {
        ContentValidator.issues(in: catalog, imageExists: imageExists)
    }
}

@MainActor
private extension Album {
    static func stub(id: String, topicIDs: [String]) -> Album {
        let black = HexColor(hex: "#000000")!
        return Album(id: id, title: id, gradient: Gradient(from: black, to: black), topicIDs: topicIDs)
    }
}

@MainActor
private extension Topic {
    static func stub(
        id: String,
        errorRegion: NormalizedRect = NormalizedRect(x: 0, y: 0, width: 0.5, height: 0.5)
    ) -> Topic {
        Topic(
            id: id,
            title: id,
            imageName: "schema",
            theory: "",
            codeSample: "",
            docsURL: URL(string: "https://www.swift.org")!,
            wrongImageNames: ["schema_broken"],
            errorRegion: errorRegion
        )
    }
}
