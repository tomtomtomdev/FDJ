import Testing
import Foundation
@testable import FDJ

struct MockAPIEndpointsTests {
    @Test("MockAPIEndpoints should provide correct URLs")
    func testEndpointURLs() {
        // When: Getting odds endpoint
        let oddsURL = MockAPIEndpoints.odds

        // Then: Should be a valid URL
        #expect(oddsURL.absoluteString.isEmpty == false)
        #expect(oddsURL.scheme == "https")
        #expect(oddsURL.host == "api.mockodds.com")
        #expect(oddsURL.path.contains("/v4/sports"))
    }

    @Test("MockAPIEndpoints should build URL with parameters")
    func testURLWithParameters() {
        // Given: Parameters
        let apiKey = "test_api_key"
        let regions = "us"
        let markets = "h2h"

        // When: Building URL with parameters
        let url = MockAPIEndpoints.buildOddsURL(apiKey: apiKey, regions: regions, markets: markets)

        // Then: Should include parameters in URL
        let urlString = url.absoluteString
        #expect(urlString.contains("apiKey=\(apiKey)"))
        #expect(urlString.contains("regions=\(regions)"))
        #expect(urlString.contains("markets=\(markets)"))
    }

    @Test("MockAPIEndpoints should handle different regions")
    func testDifferentRegions() {
        // Given: Different regions
        let usURL = MockAPIEndpoints.buildOddsURL(regions: "us")
        let euURL = MockAPIEndpoints.buildOddsURL(regions: "eu")
        let ukURL = MockAPIEndpoints.buildOddsURL(regions: "uk")

        // Then: Should have different region parameters
        #expect(usURL.absoluteString.contains("regions=us"))
        #expect(euURL.absoluteString.contains("regions=eu"))
        #expect(ukURL.absoluteString.contains("regions=uk"))
    }

    @Test("MockAPIEndpoints should handle multiple markets")
    func testMultipleMarkets() {
        // Given: Multiple markets
        let markets = "h2h,spreads,totals"

        // When: Building URL
        let url = MockAPIEndpoints.buildOddsURL(markets: markets)

        // Then: Should include all markets
        #expect(url.absoluteString.contains(markets))
    }

    @Test("MockAPIEndpoints should provide sports endpoint")
    func testSportsEndpoint() {
        // When: Getting sports endpoint
        let sportsURL = MockAPIEndpoints.sports

        // Then: Should be correct endpoint
        #expect(sportsURL.absoluteString.contains("/sports"))
        #expect(sportsURL.absoluteString.isEmpty == false)
    }

    @Test("MockAPIEndpoints should handle odds by sport")
    func testOddsBySport() {
        // Given: Sport name
        let sport = "basketball"

        // When: Building sport-specific odds URL
        let url = MockAPIEndpoints.oddsForSport(sport)

        // Then: Should include sport in path
        #expect(url.absoluteString.contains("/sports/\(sport)"))
        #expect(url.absoluteString.contains("/odds"))
    }
}