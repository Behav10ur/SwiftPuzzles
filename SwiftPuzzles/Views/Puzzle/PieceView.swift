import SwiftUI

/// One piece, cut from the image with geometry instead of copying pixels:
/// the whole image is drawn at board size, shifted so the piece's cell lands at the top-left,
/// and clipped to the cell.
struct PieceView: View {
    let imageName: String
    let piece: Int
    let grid: GridSize
    let boardSize: CGSize

    var body: some View {
        let cell = grid.cellSize(in: boardSize)
        let origin = grid.origin(of: piece, in: boardSize)

        Image(imageName)
            .resizable()
            .frame(width: boardSize.width, height: boardSize.height)
            .offset(x: -origin.x, y: -origin.y)
            .frame(width: cell.width, height: cell.height, alignment: .topLeading)
            .clipped()
    }
}

#Preview {
    // Piece 4 of a 3×4 grid: the center cell of the second row.
    PieceView(
        imageName: "mock_schema",
        piece: 4,
        grid: GridSize(columns: 3, rows: 4),
        boardSize: CGSize(width: 300, height: 400)
    )
}
