import SwiftUI

struct Album: Codable, Identifiable, Hashable {
    struct Gradient: Codable, Hashable {
        let from: HexColor
        let to: HexColor

        var linear: LinearGradient {
            LinearGradient(colors: [from.color, to.color], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    let id: String
    let title: String
    let gradient: Gradient
    /// Topics are shown in this order.
    let topicIDs: [String]

    /// Topics open one by one: the first is always open, each next one once the previous is solved.
    func isTopicUnlocked(_ topicID: String, solvedTopicIDs: Set<String>) -> Bool {
        guard let index = topicIDs.firstIndex(of: topicID) else { return false }
        return index == 0 || solvedTopicIDs.contains(topicIDs[index - 1])
    }

    func status(of topicID: String, solvedTopicIDs: Set<String>, startedTopicIDs: Set<String>) -> TopicStatus {
        if solvedTopicIDs.contains(topicID) { return .solved }
        guard isTopicUnlocked(topicID, solvedTopicIDs: solvedTopicIDs) else { return .locked }
        return startedTopicIDs.contains(topicID) ? .inProgress : .next
    }
}
