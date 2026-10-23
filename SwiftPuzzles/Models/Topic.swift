import Foundation

struct Topic: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let imageName: String
    let theory: String
    let codeSample: String
    let docsURL: URL
    /// Full copies of the schema, each with one mistake inside `errorRegion`.
    let wrongImageNames: [String]
    let errorRegion: NormalizedRect
}
