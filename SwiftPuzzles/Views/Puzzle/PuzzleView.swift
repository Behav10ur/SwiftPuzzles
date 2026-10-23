import SwiftUI

struct PuzzleView: View {
    /// All schemas are drawn in 3:4.
    private static let boardAspectRatio: CGFloat = 3 / 4

    let topic: Topic
    @State private var board: PuzzleBoard
    // Plain @State, not @GestureState: on release the swap and the reset of the offset
    // must happen in one withAnimation, while @GestureState resets on its own.
    @State private var draggedPiece: Int?
    @State private var dragTranslation: CGSize = .zero
    @Environment(\.dismiss) private var dismiss

    init(topic: Topic, grid: GridSize) {
        self.topic = topic
        // Used only when the view is first created; SwiftUI keeps the state after that.
        _board = State(initialValue: .shuffled(grid: grid))
    }

    var body: some View {
        GeometryReader { proxy in
            let boardSize = Self.fittedBoardSize(in: proxy.size)

            // Pieces are identified by piece number, not position, so a swap moves
            // the same two views to new places and the animation comes for free.
            ZStack(alignment: .topLeading) {
                ForEach(0..<board.grid.cellCount, id: \.self) { piece in
                    let position = board.position(of: piece) ?? piece
                    let origin = board.grid.origin(of: position, in: boardSize)
                    let isDragged = piece == draggedPiece

                    PieceView(
                        imageName: topic.imageName,
                        piece: piece,
                        grid: board.grid,
                        boardSize: boardSize,
                        mismatchedSides: board.mismatchedSides(of: position)
                    )
                    .shadow(radius: isDragged ? 8 : 0)
                    .offset(
                        x: origin.x + (isDragged ? dragTranslation.width : 0),
                        y: origin.y + (isDragged ? dragTranslation.height : 0)
                    )
                    .zIndex(isDragged ? 1 : 0)
                    .gesture(dragGesture(for: piece, at: position, boardSize: boardSize))
                }
            }
            .frame(width: boardSize.width, height: boardSize.height, alignment: .topLeading)
            .clipShape(.rect(cornerRadius: 16))
            .allowsHitTesting(!board.isSolved)
            .overlay {
                if board.isSolved {
                    Text("Собрано!")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: .capsule)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        // Hiding the system back button also turns off swipe-to-go-back,
        // which would otherwise fight with dragging pieces.
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Назад", systemImage: "chevron.backward") { dismiss() }
            }
        }
    }

    private func dragGesture(for piece: Int, at position: Int, boardSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // A second finger on another piece is ignored while one is being dragged.
                guard draggedPiece == nil || draggedPiece == piece else { return }
                draggedPiece = piece
                dragTranslation = value.translation
            }
            .onEnded { value in
                guard draggedPiece == piece else { return }
                // Target is the cell under the piece's center, not under the finger:
                // a piece grabbed by its corner should land where the piece itself is.
                let cell = board.grid.cellSize(in: boardSize)
                let origin = board.grid.origin(of: position, in: boardSize)
                let center = CGPoint(
                    x: origin.x + cell.width / 2 + value.translation.width,
                    y: origin.y + cell.height / 2 + value.translation.height
                )
                withAnimation(.spring(duration: 0.3)) {
                    if let target = board.grid.index(at: center, in: boardSize), target != position {
                        board.swapPieces(at: position, target)
                    }
                    draggedPiece = nil
                    dragTranslation = .zero
                }
            }
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
