import Foundation

/// Represents a bookmaker with their odds offerings
struct Bookmaker: Codable, Sendable, Identifiable, Equatable {
    let id = UUID()
    let name: String
    let outcomes: [Outcome]

    enum CodingKeys: String, CodingKey {
        case name, outcomes
    }

    var bestOutcome: Outcome? {
        outcomes.sorted { $0.price > $1.price }.first
    }

    func hasOutcome(named name: String) -> Bool {
        outcomes.contains { $0.name.lowercased() == name.lowercased() }
    }
}