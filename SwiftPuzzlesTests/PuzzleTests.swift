import CoreGraphics
import Testing
@testable import SwiftPuzzles

struct PuzzleTests {

    @Test func cellsAreNumberedRowByRow() {
        let grid = GridSize(columns: 3, rows: 4)

        #expect((grid.column(of: 0), grid.row(of: 0)) == (0, 0))
        #expect((grid.column(of: 2), grid.row(of: 2)) == (2, 0))
        #expect((grid.column(of: 3), grid.row(of: 3)) == (0, 1))
        #expect((grid.column(of: 11), grid.row(of: 11)) == (2, 3))
    }

    @Test func cellGeometryScalesWithBoard() {
        let grid = GridSize(columns: 4, rows: 5)
        let board = CGSize(width: 400, height: 500)

        #expect(grid.cellSize(in: board) == CGSize(width: 100, height: 100))
        #expect(grid.origin(of: 0, in: board) == .zero)
        #expect(grid.origin(of: 6, in: board) == CGPoint(x: 200, y: 100))
        #expect(grid.origin(of: 19, in: board) == CGPoint(x: 300, y: 400))
    }

    @Test(arguments: Difficulty.allCases)
    func shuffleMovesEveryPiece(difficulty: Difficulty) {
        let grid = difficulty.grid
        for seed in UInt64(0)..<100 {
            var generator = SeededGenerator(seed: seed)
            let board = PuzzleBoard.shuffled(grid: grid, using: &generator)

            #expect(board.slots.sorted() == Array(0..<grid.cellCount), "not a permutation, seed \(seed)")
            #expect(board.slots.indices.allSatisfy { board.slots[$0] != $0 }, "piece left in place, seed \(seed)")
        }
    }

    @Test func sameSeedGivesSameBoard() {
        var first = SeededGenerator(seed: 42)
        var second = SeededGenerator(seed: 42)

        #expect(
            PuzzleBoard.shuffled(grid: Difficulty.hard.grid, using: &first)
                == PuzzleBoard.shuffled(grid: Difficulty.hard.grid, using: &second)
        )
    }

    @Test func boardKnowsWhenItIsSolved() {
        let grid = Difficulty.easy.grid
        var generator = SeededGenerator(seed: 1)
        let shuffled = PuzzleBoard.shuffled(grid: grid, using: &generator)

        #expect(PuzzleBoard.solved(grid: grid).isSolved)
        #expect(!shuffled.isSolved)
        #expect(shuffled.position(of: shuffled.slots[5]) == 5)
    }
}

/// SplitMix64: a tiny deterministic generator, so shuffles in tests are reproducible.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) { state = seed }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
