import SwiftUI

/// Detail view for a single odds event
struct OddsDetailView: View {
    let event: OddsEvent
    @State private var viewModel: OddsDetailViewModel
    @State private var selectedOutcome: String?

    init(event: OddsEvent) {
        self.event = event
        _viewModel = State(initialValue: OddsDetailViewModel(event: event))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Event header
                eventHeaderSection

                // Time and status
                timeSection

                // Best odds overview
                if viewModel.bestOdds != nil {
                    bestOddsSection
                }

                // Arbitrage opportunity
                if let arbitrage = viewModel.calculateArbitrage() {
                    arbitrageSection(arbitrage)
                }

                // Bookmaker comparison
                bookmakersSection
            }
            .padding()
        }
        .navigationTitle("Odds Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var eventHeaderSection: some View {
        VStack(spacing: 12) {
            Text(viewModel.displayTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(viewModel.sportDisplay)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.secondary.opacity(0.2))
                .clipShape(Capsule())
        }
    }

    @ViewBuilder
    private var timeSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: viewModel.isLive ? "circle.fill" : "clock")
                    .foregroundColor(viewModel.isLive ? .red : .blue)
                    .font(.title3)

                VStack(alignment: .leading) {
                    Text(viewModel.isLive ? "Live Now" : "Starts")
                        .font(.headline)
                    Text(viewModel.commenceTimeFormatted)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !viewModel.isLive {
                    Text(viewModel.timeUntilEvent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var bestOddsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best Odds")
                .font(.headline)

            HStack(spacing: 20) {
                ForEach(viewModel.bestOdds ?? [], id: \.id) { outcome in
                    VStack(spacing: 8) {
                        Text(outcome.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(outcome.displayPrice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Text(viewModel.formatImpliedProbability(outcome.impliedProbability))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func arbitrageSection(_ arbitrage: ArbitrageInfo) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Arbitrage Opportunity", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundColor(.green)

            Text("Guaranteed profit: \(arbitrage.formattedProfitMargin)")
                .font(.subheadline)
                .fontWeight(.medium)

            Text("Total implied probability: \(String(format: "%.1f%%", arbitrage.totalImpliedProbability * 100))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .foregroundStyle(.green)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var bookmakersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Bookmakers")
                .font(.headline)

            ForEach(viewModel.bookmakers, id: \.id) { bookmaker in
                BookmakerRow(
                    bookmaker: bookmaker,
                    selectedOutcome: $selectedOutcome
                )
            }
        }
    }
}

// MARK: - BookmakerRow Component
struct BookmakerRow: View {
    let bookmaker: Bookmaker
    @Binding var selectedOutcome: String?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(bookmaker.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                if let best = bookmaker.bestOutcome {
                    Text("Best: \(best.name)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            HStack(spacing: 12) {
                ForEach(bookmaker.outcomes, id: \.id) { outcome in
                    Button(action: {
                        selectedOutcome = outcome.name
                    }) {
                        VStack(spacing: 4) {
                            Text(outcome.name)
                                .font(.caption2)
                                .lineLimit(1)

                            Text(outcome.displayPrice)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedOutcome == outcome.name ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedOutcome == outcome.name ? Color.blue : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        OddsDetailView(
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
                    ),
                    Bookmaker(
                        name: "FanDuel",
                        outcomes: [
                            Outcome(name: "Lakers", price: 1.90),
                            Outcome(name: "Warriors", price: 1.90)
                        ]
                    )
                ]
            )
        )
    }
    .preferredColorScheme(.dark)
}