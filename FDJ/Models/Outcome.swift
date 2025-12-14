import Foundation

/// Represents a betting outcome with associated odds
struct Outcome: Codable, Sendable, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let price: Double
    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case name, price
    }

    var displayPrice: String {
        return String(format: "%.2f", price)
    }

    var impliedProbability: Double {
        guard price > 0 else { return 0 }
        return 1 / price * 100
    }
}