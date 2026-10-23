import Foundation

/// String raw values let `@AppStorage` persist the choice in UserDefaults.
nonisolated enum Difficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard

    static let storageKey = "difficulty"

    var id: Self { self }

    var grid: GridSize {
        switch self {
        case .easy: GridSize(columns: 3, rows: 4)
        case .medium: GridSize(columns: 4, rows: 5)
        case .hard: GridSize(columns: 5, rows: 6)
        }
    }

    var title: String { "\(grid.columns) × \(grid.rows)" }
}
