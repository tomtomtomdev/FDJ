import Testing
import Foundation
@testable import FDJ

struct OutcomeTests {
    @Test("Outcome should initialize with correct properties")
    func testOutcomeInitialization() {
        // Given: Expected values
        let name = "Lakers"
        let price = 1.85

        // When: Creating an Outcome
        let outcome = Outcome(name: name, price: price)

        // Then: Properties should match
        #expect(outcome.name == name)
        #expect(outcome.price == price)
        #expect(outcome.isFavorite == false)
        #expect(outcome.id != UUID()) // Should have a unique ID
    }

    @Test("Outcome should display price correctly")
    func testDisplayPrice() {
        // Given: An outcome with price
        let outcome = Outcome(name: "Test", price: 1.85)

        // When: Getting display price
        let displayPrice = outcome.displayPrice

        // Then: Should format to 2 decimal places
        #expect(displayPrice == "1.85")
    }

    @Test("Outcome should calculate implied probability")
    func testImpliedProbability() {
        // Given: An outcome with even odds (2.0)
        let outcome = Outcome(name: "Test", price: 2.0)

        // When: Calculating implied probability
        let probability = outcome.impliedProbability

        // Then: Should be 50% for even odds
        #expect(abs(probability - 50.0) < 0.01)
    }

    @Test("Outcome should handle zero price")
    func testZeroPriceImpliedProbability() {
        // Given: An outcome with zero price
        let outcome = Outcome(name: "Test", price: 0)

        // When: Calculating implied probability
        let probability = outcome.impliedProbability

        // Then: Should return 0
        #expect(probability == 0)
    }

    @Test("Outcome should be Equatable")
    func testOutcomeEquality() {
        // Given: Two outcomes with same properties
        let outcome1 = Outcome(name: "Lakers", price: 1.85)
        let outcome2 = Outcome(name: "Lakers", price: 1.85)

        // Then: Should be equal
        #expect(outcome1 == outcome2)
    }

    @Test("Outcome should be Codable")
    func testOutcomeCodable() throws {
        // Given: An Outcome instance
        let outcome = Outcome(name: "Lakers", price: 1.85)

        // When: Encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(outcome)
        let decodedOutcome = try decoder.decode(Outcome.self, from: data)

        // Then: Should maintain properties
        #expect(decodedOutcome.name == outcome.name)
        #expect(decodedOutcome.price == outcome.price)
        #expect(decodedOutcome.isFavorite == false) // Default value
    }
}