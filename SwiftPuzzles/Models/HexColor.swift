import SwiftUI

/// An sRGB color stored in JSON as "#RRGGBB". Invalid strings fail at decoding time, like a bad URL.
struct HexColor: Codable, Hashable {
    let red: Double
    let green: Double
    let blue: Double

    init?(hex: String) {
        let digits = hex.dropFirst()
        // isHexDigit check: UInt32(_:radix:) would also accept a leading "+".
        guard hex.hasPrefix("#"), digits.count == 6, digits.allSatisfy(\.isHexDigit),
              let value = UInt32(digits, radix: 16) else { return nil }
        red = Double((value >> 16) & 0xFF) / 255
        green = Double((value >> 8) & 0xFF) / 255
        blue = Double(value & 0xFF) / 255
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let color = HexColor(hex: string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "'\(string)' is not a #RRGGBB color"
            )
        }
        self = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let components = [red, green, blue].map { Int(($0 * 255).rounded()) }
        try container.encode("#" + components.map { String(format: "%02X", $0) }.joined())
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }
}
