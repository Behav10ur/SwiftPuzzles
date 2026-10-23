import Foundation

/// Arrangement of pieces on the board. Keeps its own grid, so a started puzzle
/// survives a difficulty change in settings.
nonisolated struct PuzzleBoard: Codable, Equatable {
    let grid: GridSize
    /// `slots[position]` is the piece lying at `position`. Piece N belongs at position N.
    private(set) var slots: [Int]

    init(grid: GridSize, slots: [Int]) {
        precondition(slots.sorted() == Array(0..<grid.cellCount), "slots must contain every piece exactly once")
        self.grid = grid
        self.slots = slots
    }

    var isSolved: Bool { slots == Array(slots.indices) }

    func position(of piece: Int) -> Int? {
        slots.firstIndex(of: piece)
    }

    mutating func swapPieces(at first: Int, _ second: Int) {
        slots.swapAt(first, second)
    }

    /// Sides of `position` where the neighbouring piece is not the one that belongs there.
    func mismatchedSides(of position: Int) -> Set<GridSize.Side> {
        let piece = slots[position]
        var sides: Set<GridSize.Side> = []
        for side in GridSize.Side.allCases {
            guard let neighborPosition = grid.neighbor(of: position, toward: side) else { continue }
            // Piece N belongs at cell N, so its rightful neighbour is simply the neighbour of cell N.
            if grid.neighbor(of: piece, toward: side) != slots[neighborPosition] {
                sides.insert(side)
            }
        }
        return sides
    }

    static func solved(grid: GridSize) -> PuzzleBoard {
        PuzzleBoard(grid: grid, slots: Array(0..<grid.cellCount))
    }

    /// Sattolo's algorithm: a random single-cycle permutation, so no piece starts in its own slot.
    static func shuffled(grid: GridSize, using generator: inout some RandomNumberGenerator) -> PuzzleBoard {
        var slots = Array(0..<grid.cellCount)
        for i in stride(from: slots.count - 1, to: 0, by: -1) {
            // 0..<i, not Fisher–Yates' 0...i: an element is never swapped with itself.
            let j = Int.random(in: 0..<i, using: &generator)
            slots.swapAt(i, j)
        }
        return PuzzleBoard(grid: grid, slots: slots)
    }

    static func shuffled(grid: GridSize) -> PuzzleBoard {
        var generator = SystemRandomNumberGenerator()
        return shuffled(grid: grid, using: &generator)
    }
}
