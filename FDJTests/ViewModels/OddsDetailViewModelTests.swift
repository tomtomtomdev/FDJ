import Testing
import Foundation
@testable import FDJ

struct OddsDetailViewModelTests {
    @Test("OddsDetailViewModel should initialize with event")
    func testInitialization() async {
        // Given: An odds event
        let event = createTestEvent()

        // When: Creating view model with event
        let viewModel = OddsDetailViewModel(event: event)

        // Then: Should display event details
        #expect(viewModel.event.id == event.id)
        #expect(viewModel.event.displayTitle == event.displayTitle)
        #expect(viewModel.bookmakers.count == event.bookmakers.count)
    }

    @Test("OddsDetailViewModel should format commence time")
    func testCommenceTimeFormatting() {
        // Given: A view model with future event
        let event = createTestEvent()
        let viewModel = OddsDetailViewModel(event: event)

        // When: Getting formatted time
        let formattedTime = viewModel.commenceTimeFormatted

        // Then: Should return formatted string
        #expect(formattedTime.isEmpty == false)
        #expect(formattedTime.contains(event.commenceTime.formatted(.dateTime.day().month().year())) == false)
    }

    @Test("OddsDetailViewModel should determine if event is live")
    func testIsLive() {
        // Given: A future event
        let futureEvent = OddsEvent(
            id: "future",
            sport: "basketball",
            homeTeam: "Team A",
            awayTeam: "Team B",
            commenceTime: Date().addingTimeInterval(3600),
            bookmakers: []
        )

        // When: Creating view model
        let futureViewModel = OddsDetailViewModel(event: futureEvent)

        // Then: Should not be live
        #expect(futureViewModel.isLive == false)

        // Given: A past event
        let pastEvent = OddsEvent(
            id: "past",
            sport: "basketball",
            homeTeam: "Team A",
            awayTeam: "Team B",
            commenceTime: Date().addingTimeInterval(-3600),
            bookmakers: []
        )

        // When: Creating view model
        let pastViewModel = OddsDetailViewModel(event: pastEvent)

        // Then: Should be live
        #expect(pastViewModel.isLive == true)
    }

    @Test("OddsDetailViewModel should get best odds")
    func testBestOdds() {
        // Given: An event with multiple bookmakers
        let event = createTestEvent()
        let viewModel = OddsDetailViewModel(event: event)

        // When: Getting best odds
        let bestOdds = viewModel.bestOdds

        // Then: Should return best odds across bookmakers
        #expect(bestOdds != nil)
        #expect(bestOdds?.count == 2) // Home and Away outcomes
    }

    @Test("OddsDetailViewModel should format implied probability")
    func testImpliedProbabilityFormatting() {
        // Given: A view model
        let viewModel = OddsDetailViewModel(event: createTestEvent())

        // When: Formatting probabilities
        let prob50 = viewModel.formatImpliedProbability(0.50)
        let prob75 = viewModel.formatImpliedProbability(0.75)
        let prob33 = viewModel.formatImpliedProbability(0.333)

        // Then: Should format as percentage
        #expect(prob50 == "50%")
        #expect(prob75 == "75%")
        #expect(prob33 == "33%")
    }

    @Test("OddsDetailViewModel should compare bookmaker odds")
    func testCompareBookmakerOdds() {
        // Given: An event with multiple bookmakers
        let event = createTestEvent()
        let viewModel = OddsDetailViewModel(event: event)

        // When: Getting odds comparison
        let comparison = viewModel.compareOddsForOutcome("Lakers")

        // Then: Should return comparison data
        #expect(comparison.isEmpty == false)
        #expect(comparison.count <= event.bookmakers.count)
    }

    @Test("OddsDetailViewModel should get unique outcomes")
    func testUniqueOutcomes() {
        // Given: An event
        let event = createTestEvent()
        let viewModel = OddsDetailViewModel(event: event)

        // When: Getting unique outcomes
        let uniqueOutcomes = viewModel.uniqueOutcomes

        // Then: Should return unique outcome names
        #expect(uniqueOutcomes.contains("Lakers"))
        #expect(uniqueOutcomes.contains("Warriors"))
        #expect(uniqueOutcomes.count == 2)
    }

    @Test("OddsDetailViewModel should identify best bookmaker")
    func testBestBookmaker() {
        // Given: An event with multiple bookmakers
        let event = createTestEvent()
        let viewModel = OddsDetailViewModel(event: event)

        // When: Finding best bookmaker for an outcome
        let bestBookmaker = viewModel.bestBookmakerForOutcome("Lakers")

        // Then: Should return bookmaker with highest odds
        #expect(bestBookmaker != nil)
        #expect(bestBookmaker?.name.isEmpty == false)
    }

    // MARK: - Helper Methods

    private func createTestEvent() -> OddsEvent {
        return OddsEvent(
            id: "test_event",
            sport: "basketball",
            homeTeam: "Lakers",
            awayTeam: "Warriors",
            commenceTime: Date().addingTimeInterval(3600),
            bookmakers: [
                Bookmaker(
                    name: "DraftKings",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.85),
                        Outcome(name: "Warriors", price: 1.95)
                    ]
                ),
                Bookmaker(
                    name: "FanDuel",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.90),
                        Outcome(name: "Warriors", price: 1.90)
                    ]
                ),
                Bookmaker(
                    name: "BetMGM",
                    outcomes: [
                        Outcome(name: "Lakers", price: 1.82),
                        Outcome(name: "Warriors", price: 1.98)
                    ]
                )
            ]
        )
    }
}