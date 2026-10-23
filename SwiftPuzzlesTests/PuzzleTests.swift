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

    @Test func pointMapsToCell() {
        let grid = GridSize(columns: 3, rows: 4)
        let board = CGSize(width: 300, height: 400)

        #expect(grid.index(at: CGPoint(x: 150, y: 150), in: board) == 4)
        #expect(grid.index(at: CGPoint(x: 100, y: 0), in: board) == 1, "a boundary belongs to the next cell")
        #expect(grid.index(at: CGPoint(x: 299.9, y: 399.9), in: board) == 11)
        #expect(grid.index(at: CGPoint(x: -1, y: 50), in: board) == nil)
        #expect(grid.index(at: CGPoint(x: 300, y: 50), in: board) == nil)
        #expect(grid.index(at: CGPoint(x: 50, y: 400), in: board) == nil)
    }

    @Test func neighborsStopAtEdges() {
        let grid = GridSize(columns: 3, rows: 4)

        #expect(grid.neighbor(of: 0, toward: .top) == nil)
        #expect(grid.neighbor(of: 0, toward: .left) == nil)
        #expect(grid.neighbor(of: 0, toward: .right) == 1)
        #expect(grid.neighbor(of: 0, toward: .bottom) == 3)
        #expect(grid.neighbor(of: 2, toward: .right) == nil, "no wrapping to the next row")
        #expect(grid.neighbor(of: 3, toward: .left) == nil)
        #expect(grid.neighbor(of: 11, toward: .bottom) == nil)
    }

    @Test func swappingBackSolvesBoard() {
        var board = PuzzleBoard.solved(grid: Difficulty.easy.grid)

        board.swapPieces(at: 0, 5)
        #expect(!board.isSolved)
        #expect(board.slots[0] == 5 && board.slots[5] == 0)

        board.swapPieces(at: 0, 5)
        #expect(board.isSolved)
    }

    @Test func solvedBoardHasNoMismatches() {
        let board = PuzzleBoard.solved(grid: Difficulty.medium.grid)

        #expect(board.slots.indices.allSatisfy { board.mismatchedSides(of: $0).isEmpty })
    }

    @Test func swappedPiecesMismatchTheirNeighbors() {
        // 3×4 with pieces 0 and 1 swapped: [1, 0, 2, 3, ...]
        var board = PuzzleBoard.solved(grid: Difficulty.easy.grid)
        board.swapPieces(at: 0, 1)

        #expect(board.mismatchedSides(of: 0) == [.right, .bottom])
        #expect(board.mismatchedSides(of: 1) == [.left, .right, .bottom])
        #expect(board.mismatchedSides(of: 2) == [.left])
        #expect(board.mismatchedSides(of: 4) == [.top])
    }

    @Test func nextNumberAcrossRowBreakIsNotANeighbor() {
        // On 3×4, piece 3 starts the second row, so it does not fit to the right of piece 2.
        let board = PuzzleBoard(grid: Difficulty.easy.grid, slots: [2, 3, 0, 1] + Array(4..<12))

        #expect(board.mismatchedSides(of: 0).contains(.right))
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
