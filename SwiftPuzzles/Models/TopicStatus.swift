import Foundation

enum TopicStatus {
    /// The previous topic in the album is not solved yet.
    case locked
    /// Unlocked but not started: the one to play next.
    case next
    /// Puzzle started but not finished.
    case inProgress
    case solved
}
