import Testing
import Foundation
@testable import FDJ

struct BookmakerTests {
    @Test("Bookmaker should initialize with correct properties")
    func testBookmakerInitialization() {
        // Given: Expected values
        let name = "TestBookmaker"
        let outcomes = [
            Outcome(name: "Lakers", price: 1.85),
            Outcome(name: "Warriors", price: 1.95)
        ]

        // When: Creating a Bookmaker
        let bookmaker = Bookmaker(name: name, outcomes: outcomes)

        // Then: Properties should match
        #expect(bookmaker.name == name)
        #expect(bookmaker.outcomes.count == 2)
        #expect(bookmaker.id != UUID()) // Should have a unique ID
    }

    @Test("Bookmaker should find best outcome")
    func testBestOutcome() {
        // Given: A bookmaker with multiple outcomes
        let bookmaker = Bookmaker(
            name: "TestBookmaker",
            outcomes: [
                Outcome(name: "Lakers", price: 1.85),
                Outcome(name: "Warriors", price: 1.95),
                Outcome(name: "Draw", price: 3.50)
            ]
        )

        // When: Getting best outcome
        let bestOutcome = bookmaker.bestOutcome

        // Then: Should return outcome with highest price
        #expect(bestOutcome?.name == "Draw")
        #expect(bestOutcome?.price == 3.50)
    }

    @Test("Bookmaker should handle empty outcomes")
    func testBestOutcomeEmpty() {
        // Given: A bookmaker with no outcomes
        let bookmaker = Bookmaker(name: "TestBookmaker", outcomes: [])

        // When: Getting best outcome
        let bestOutcome = bookmaker.bestOutcome

        // Then: Should return nil
        #expect(bestOutcome == nil)
    }

    @Test("Bookmaker should check for outcome existence")
    func testHasOutcome() {
        // Given: A bookmaker with specific outcomes
        let bookmaker = Bookmaker(
            name: "TestBookmaker",
            outcomes: [
                Outcome(name: "Lakers", price: 1.85),
                Outcome(name: "Warriors", price: 1.95)
            ]
        )

        // When & Then: Should find existing outcomes
        #expect(bookmaker.hasOutcome(named: "Lakers") == true)
        #expect(bookmaker.hasOutcome(named: "Warriors") == true)

        // Case insensitive check
        #expect(bookmaker.hasOutcome(named: "lakers") == true)
        #expect(bookmaker.hasOutcome(named: "LAKERS") == true)

        // Should not find non-existent outcomes
        #expect(bookmaker.hasOutcome(named: "Bulls") == false)
    }

    @Test("Bookmaker should be Equatable")
    func testBookmakerEquality() {
        // Given: Two bookmakers with same properties
        let outcomes = [
            Outcome(name: "Lakers", price: 1.85),
            Outcome(name: "Warriors", price: 1.95)
        ]
        let bookmaker1 = Bookmaker(name: "TestBookmaker", outcomes: outcomes)
        let bookmaker2 = Bookmaker(name: "TestBookmaker", outcomes: outcomes)

        // Then: Should be equal
        #expect(bookmaker1 == bookmaker2)
    }

    @Test("Bookmaker should be Codable")
    func testBookmakerCodable() throws {
        // Given: A Bookmaker instance
        let bookmaker = Bookmaker(
            name: "TestBookmaker",
            outcomes: [
                Outcome(name: "Lakers", price: 1.85),
                Outcome(name: "Warriors", price: 1.95)
            ]
        )

        // When: Encoding and decoding
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(bookmaker)
        let decodedBookmaker = try decoder.decode(Bookmaker.self, from: data)

        // Then: Should maintain properties
        #expect(decodedBookmaker.name == bookmaker.name)
        #expect(decodedBookmaker.outcomes.count == bookmaker.outcomes.count)
        #expect(decodedBookmaker.outcomes[0].name == bookmaker.outcomes[0].name)
    }
}