import Foundation

/// A rectangle in image-relative coordinates (0...1), so it stays valid for any grid size.
struct NormalizedRect: Codable, Equatable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    var isWithinUnitSquare: Bool {
        x >= 0 && y >= 0 && width > 0 && height > 0
            && x + width <= 1 && y + height <= 1
    }
}
