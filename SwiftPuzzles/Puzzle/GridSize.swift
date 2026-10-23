import CoreGraphics

/// Cells are numbered row by row, left to right: 0 is top-left, `cellCount - 1` is bottom-right.
nonisolated struct GridSize: Codable, Hashable {
    let columns: Int
    let rows: Int

    var cellCount: Int { columns * rows }

    func column(of index: Int) -> Int { index % columns }
    func row(of index: Int) -> Int { index / columns }

    func cellSize(in boardSize: CGSize) -> CGSize {
        CGSize(width: boardSize.width / CGFloat(columns), height: boardSize.height / CGFloat(rows))
    }

    /// Top-left corner of the cell on a board of the given size.
    func origin(of index: Int, in boardSize: CGSize) -> CGPoint {
        let cell = cellSize(in: boardSize)
        return CGPoint(x: CGFloat(column(of: index)) * cell.width, y: CGFloat(row(of: index)) * cell.height)
    }
}
