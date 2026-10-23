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

    /// The cell under `point`, or nil if the point is outside the board.
    func index(at point: CGPoint, in boardSize: CGSize) -> Int? {
        guard point.x >= 0, point.y >= 0, point.x < boardSize.width, point.y < boardSize.height else {
            return nil
        }
        let cell = cellSize(in: boardSize)
        return Int(point.y / cell.height) * columns + Int(point.x / cell.width)
    }

    /// The adjacent cell, or nil at the board's edge (no wrapping to the next row).
    func neighbor(of index: Int, toward side: Side) -> Int? {
        let column = self.column(of: index)
        let row = self.row(of: index)
        switch side {
        case .top: return row > 0 ? index - columns : nil
        case .bottom: return row < rows - 1 ? index + columns : nil
        case .left: return column > 0 ? index - 1 : nil
        case .right: return column < columns - 1 ? index + 1 : nil
        }
    }
}

extension GridSize {
    nonisolated enum Side: CaseIterable {
        case top, bottom, left, right
    }
}
