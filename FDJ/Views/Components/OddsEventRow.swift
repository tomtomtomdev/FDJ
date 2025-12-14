import SwiftUI

/// Row component displaying a single odds event
struct OddsEventRow: View {
    let event: OddsEvent
    let onFavoriteToggle: (OddsEvent) -> Void

    init(event: OddsEvent, onFavoriteToggle: @escaping (OddsEvent) -> Void = { _ in }) {
        self.event = event
        self.onFavoriteToggle = onFavoriteToggle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with teams and sport
            headerView

            // Time information
            timeView

            // Best odds
            if let bestOdds = event.bestOddsAcrossBookmakers {
                bestOddsView(bestOdds)
            }

            // Live indicator
            if event.isLive {
                liveIndicator
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(event.sportDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }

            Spacer()

            HStack(spacing: 12) {
                if event.isLive {
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                }

                Button(action: {
                    onFavoriteToggle(event)
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var timeView: some View {
        HStack {
            Image(systemName: "clock")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(event.timeUntilEvent)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func bestOddsView(_ odds: [Outcome]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Best Odds")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(odds) { outcome in
                    VStack(alignment: .center, spacing: 2) {
                        Text(outcome.name)
                            .font(.caption2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text(outcome.displayPrice)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    @ViewBuilder
    private var liveIndicator: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(.red)
                .font(.caption2)

            Text("Event in progress")
                .font(.caption2)
                .foregroundStyle(.red)

            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - Preview
#Preview {
    List {
        OddsEventRow(
            event: OddsEvent(
                id: "1",
                sport: "basketball",
                homeTeam: "Los Angeles Lakers",
                awayTeam: "Golden State Warriors",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: [
                    Bookmaker(
                        name: "DraftKings",
                        outcomes: [
                            Outcome(name: "Lakers", price: 1.85),
                            Outcome(name: "Warriors", price: 1.95)
                        ]
                    )
                ]
            )
        )

        OddsEventRow(
            event: OddsEvent(
                id: "2",
                sport: "football",
                homeTeam: "New England Patriots",
                awayTeam: "Buffalo Bills",
                commenceTime: Date().addingTimeInterval(-3600),
                bookmakers: [
                    Bookmaker(
                        name: "BetMGM",
                        outcomes: [
                            Outcome(name: "Patriots", price: 2.10),
                            Outcome(name: "Bills", price: 1.80),
                            Outcome(name: "Draw", price: 3.40)
                        ]
                    )
                ]
            )
        )
    }
    .listStyle(PlainListStyle())
    .preferredColorScheme(.dark)
}