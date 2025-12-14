import Testing
import Foundation
@testable import FDJ

struct OddsEventTests {
    @Test("OddsEvent should initialize with correct properties")
    func testOddsEventInitialization() {
        // Given: Expected values
        let id = "test_event_1"
        let sport = "basketball"
        let homeTeam = "Lakers"
        let awayTeam = "Warriors"
        let commenceTime = Date()
        let bookmakers: [Bookmaker] = []

        // When: Creating an OddsEvent
        let event = OddsEvent(
            id: id,
            sport: sport,
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            commenceTime: commenceTime,
            bookmakers: bookmakers
        )

        // Then: Properties should match
        #expect(event.id == id)
        #expect(event.sport == sport)
        #expect(event.homeTeam == homeTeam)
        #expect(event.awayTeam == awayTeam)
        #expect(event.commenceTime == commenceTime)
        #expect(event.bookmakers.isEmpty == true)
    }

    @Test("OddsEvent should display title correctly")
    func testDisplayTitle() {
        // Given: An odds event
        let event = OddsEvent(
            id: "test",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date(),
            bookmakers: []
        )

        // When: Getting display title
        let title = event.displayTitle

        // Then: Should format as "Home vs Away"
        #expect(title == "Lakers vs Warriors")
    }

    @Test("OddsEvent should display sport name correctly")
    func testSportDisplay() {
        // Given: An odds event with lowercase sport
        let event = OddsEvent(
            id: "test",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date(),
            bookmakers: []
        )

        // When: Getting sport display
        let sportDisplay = event.sportDisplay

        // Then: Should capitalize the sport name
        #expect(sportDisplay == "Basketball")
    }

    @Test("OddsEvent should determine if live correctly")
    func testIsLive() {
        // Given: An event that already started
        let pastEvent = OddsEvent(
            id: "past",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date().addingTimeInterval(-3600), // 1 hour ago
            bookmakers: []
        )

        // Given: An event that will start in the future
        let futureEvent = OddsEvent(
            id: "future",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date().addingTimeInterval(3600), // 1 hour from now
            bookmakers: []
        )

        // When/Then: Should correctly determine live status
        #expect(pastEvent.isLive == true)
        #expect(futureEvent.isLive == false)
    }

    @Test("OddsEvent should calculate best odds across bookmakers")
    func testBestOddsAcrossBookmakers() {
        // Given: Multiple bookmakers with different odds
        let event = OddsEvent(
            id: "test",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date(),
            bookmakers: [
                Bookmaker(
                    name: "Bookmaker1",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.85),
                        Outcome(name: "Warriors", price: 1.95)
                    ]
                ),
                Bookmaker(
                    name: "Bookmaker2",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.90), // Better price
                        Outcome(name: "Warriors", price: 1.90)
                    ]
                )
            ]
        )

        // When: Getting best odds across bookmakers
        let bestOdds = event.bestOddsAcrossBookmakers

        // Then: Should select the best price for each outcome
        #expect(bestOdds?.count == 2)
        let lakersBest = bestOdds?.first { $0.name == "Lakers" }
        let warriorsBest = bestOdds?.first { $0.name == "Warriors" }
        #expect(lakersBest?.price == 1.90)
        #expect(warriorsBest?.price == 1.95)
    }

    @Test("OddsEvent should handle empty bookmakers")
    func testBestOddsEmptyBookmakers() {
        // Given: An event with no bookmakers
        let event = OddsEvent(
            id: "test",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date(),
            bookmakers: []
        )

        // When: Getting best odds
        let bestOdds = event.bestOddsAcrossBookmakers

        // Then: Should return nil
        #expect(bestOdds == nil)
    }

    @Test("OddsEvent should be Codable")
    func testOddsEventCodable() throws {
        // Given: An OddsEvent instance
        let event = OddsEvent(
            id: "test_event_1",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date(),
            bookmakers: [
                Bookmaker(
                    name: "TestBookmaker",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.85),
                        Outcome(name: "Warriors", price: 1.95)
                    ]
                )
            ]
        )

        // When: Encoding and decoding
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let data = try encoder.encode(event)
        let decodedEvent = try decoder.decode(OddsEvent.self, from: data)

        // Then: Should maintain properties
        #expect(decodedEvent.id == event.id)
        #expect(decodedEvent.sport == event.sport)
        #expect(decodedEvent.homeTeam == event.homeTeam)
        #expect(decodedEvent.awayTeam == event.awayTeam)
    }
}