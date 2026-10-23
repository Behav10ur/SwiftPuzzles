import SwiftUI

struct PuzzleView: View {
    /// All schemas are drawn in 3:4.
    private static let boardAspectRatio: CGFloat = 3 / 4

    let topic: Topic
    @State private var board: PuzzleBoard

    init(topic: Topic, grid: GridSize) {
        self.topic = topic
        // Used only when the view is first created; SwiftUI keeps the state after that.
        _board = State(initialValue: .shuffled(grid: grid))
    }

    var body: some View {
        GeometryReader { proxy in
            let boardSize = Self.fittedBoardSize(in: proxy.size)

            // Pieces are identified by piece number, not position, so in stage 3
            // a swap moves the same view to a new place instead of redrawing two.
            ZStack(alignment: .topLeading) {
                ForEach(0..<board.grid.cellCount, id: \.self) { piece in
                    let origin = board.grid.origin(of: board.position(of: piece) ?? piece, in: boardSize)
                    PieceView(imageName: topic.imageName, piece: piece, grid: board.grid, boardSize: boardSize)
                        // strokeBorder draws inside the piece, so two neighbours add up to a 2 pt line.
                        .overlay { Rectangle().strokeBorder(.black.opacity(0.6), lineWidth: 1) }
                        .offset(x: origin.x, y: origin.y)
                }
            }
            .frame(width: boardSize.width, height: boardSize.height, alignment: .topLeading)
            .clipShape(.rect(cornerRadius: 16))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private static func fittedBoardSize(in available: CGSize) -> CGSize {
        let width = min(available.width, available.height * boardAspectRatio)
        return CGSize(width: width, height: width / boardAspectRatio)
    }
}

#Preview {
    let catalog = ContentLoader.loadOrCrash()
    NavigationStack {
        PuzzleView(topic: catalog.topics[0], grid: Difficulty.easy.grid)
    }
}
