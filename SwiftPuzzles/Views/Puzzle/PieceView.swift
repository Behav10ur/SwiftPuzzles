import SwiftUI

/// One piece, cut from the image with geometry instead of copying pixels:
/// the whole image is drawn at board size, shifted so the piece's cell lands at the top-left,
/// and clipped to the cell.
struct PieceView: View {
    let imageName: String
    let piece: Int
    let grid: GridSize
    let boardSize: CGSize
    /// Sides drawn with a dark line because the neighbour there does not fit.
    let mismatchedSides: Set<GridSize.Side>

    var body: some View {
        let cell = grid.cellSize(in: boardSize)
        let origin = grid.origin(of: piece, in: boardSize)

        Image(imageName)
            .resizable()
            .frame(width: boardSize.width, height: boardSize.height)
            .offset(x: -origin.x, y: -origin.y)
            .frame(width: cell.width, height: cell.height, alignment: .topLeading)
            .clipped()
            // clipped() only clips drawing: without this, the hidden board-sized image
            // would still catch touches across the whole board.
            .contentShape(.rect)
            .overlay { PieceBorder(sides: mismatchedSides) }
    }
}

/// Lines are drawn inside the piece, so two mismatched neighbours add up to a 2 pt line.
private struct PieceBorder: View {
    let sides: Set<GridSize.Side>

    private let width: CGFloat = 1
    private let color = Color.black.opacity(0.6)

    var body: some View {
        ZStack {
            if sides.contains(.top) {
                color.frame(height: width).frame(maxHeight: .infinity, alignment: .top)
            }
            if sides.contains(.bottom) {
                color.frame(height: width).frame(maxHeight: .infinity, alignment: .bottom)
            }
            if sides.contains(.left) {
                color.frame(width: width).frame(maxWidth: .infinity, alignment: .leading)
            }
            if sides.contains(.right) {
                color.frame(width: width).frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    // Piece 4 of a 3×4 grid: the center cell of the second row.
    PieceView(
        imageName: "mock_schema",
        piece: 4,
        grid: GridSize(columns: 3, rows: 4),
        boardSize: CGSize(width: 300, height: 400),
        mismatchedSides: [.top, .right]
    )
}
