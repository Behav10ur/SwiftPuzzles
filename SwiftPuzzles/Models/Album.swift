import Foundation

struct Album: Codable, Identifiable {
    let id: String
    let title: String
    /// Topics are shown in this order.
    let topicIDs: [String]
}
