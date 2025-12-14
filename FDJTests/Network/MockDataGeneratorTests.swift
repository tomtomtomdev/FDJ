import Testing
import Foundation
@testable import FDJ

struct MockDataGeneratorTests {
    @Test("MockDataGenerator should generate realistic odds events")
    func testGenerateOddsEvents() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating odds events
        let events = await generator.generateOddsEvents()

        // Then: Should return multiple events
        #expect(events.isEmpty == false)
        #expect(events.count >= 3) // At least basketball, football, and soccer

        // And: Each event should have valid data
        for event in events {
            #expect(event.id.isEmpty == false)
            #expect(event.sport.isEmpty == false)
            #expect(event.homeTeam.isEmpty == false)
            #expect(event.awayTeam.isEmpty == false)
            #expect(event.bookmakers.isEmpty == false)
        }
    }

    @Test("MockDataGenerator should include multiple sports")
    func testMultipleSports() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating events
        let events = await generator.generateOddsEvents()

        // Then: Should include different sports
        let sports = Set(events.map { $0.sport })
        #expect(sports.contains("basketball"))
        #expect(sports.contains("football"))
        #expect(sports.contains("soccer"))
    }

    @Test("MockDataGenerator should generate realistic odds")
    func testRealisticOdds() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating events
        let events = await generator.generateOddsEvents()

        // Then: Odds should be realistic (between 1.01 and 10.0)
        for event in events {
            for bookmaker in event.bookmakers {
                for outcome in bookmaker.outcomes {
                    #expect(outcome.price >= 1.01)
                    #expect(outcome.price <= 10.0)
                }
            }
        }
    }

    @Test("MockDataGenerator should generate unique events")
    func testUniqueEvents() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating events twice
        let events1 = await generator.generateOddsEvents()
        let events2 = await generator.generateOddsEvents()

        // Then: Should have different IDs
        let ids1 = Set(events1.map { $0.id })
        let ids2 = Set(events2.map { $0.id })
        #expect(ids1.intersection(ids2).isEmpty)
    }

    @Test("MockDataGenerator should create events in the future")
    func testFutureEvents() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating events
        let events = await generator.generateOddsEvents()

        // Then: All events should be in the future
        let now = Date()
        for event in events {
            #expect(event.commenceTime > now)
        }
    }

    @Test("MockDataGenerator should handle different event counts")
    func testDifferentEventCounts() async {
        // Given: Mock data generator
        let generator = MockDataGenerator()

        // When: Generating specific number of events
        let singleEvent = await generator.generateOddsEvents(count: 1)
        let multipleEvents = await generator.generateOddsEvents(count: 5)

        // Then: Should return correct number of events
        #expect(singleEvent.count == 1)
        #expect(multipleEvents.count == 5)
    }
}