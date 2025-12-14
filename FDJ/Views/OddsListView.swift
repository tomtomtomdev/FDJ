import SwiftUI

/// Main view displaying a list of sports odds events
struct OddsListView: View {
    @State private var viewModel: OddsListViewModel
    @State private var selectedEvent: OddsEvent?
    @State private var showingSearch = false

    init(viewModel: OddsListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.odds.isEmpty {
                    LoadingView(message: "Loading odds...")
                } else if let error = viewModel.error {
                    ErrorView(
                        error: error,
                        retryAction: {
                            Task {
                                await viewModel.loadOdds()
                            }
                        }
                    )
                } else if viewModel.filteredOdds.isEmpty && viewModel.hasFilteredResults {
                    ContentUnavailableView.search(text: viewModel.selectedSport ?? "")
                } else if viewModel.filteredOdds.isEmpty {
                    ContentUnavailableView(
                        "No Odds Available",
                        systemImage: "sportscourt",
                        description: Text("Pull to refresh to load the latest odds")
                    )
                } else {
                    oddsList
                }
            }
            .navigationTitle("Sports Odds")
            .navigationDestination(item: $selectedEvent) { event in
                OddsDetailView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }

                if viewModel.hasFilteredResults {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Clear") {
                            viewModel.clearFilter()
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.refreshOdds()
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadOdds()
        }
    }

    @ViewBuilder
    private var oddsList: some View {
        List(viewModel.filteredOdds) { event in
            NavigationLink(value: event) {
                OddsEventRow(event: event)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Preview
#Preview {
    let mockRepository = MockOddsRepository()
    let viewModel = OddsListViewModel(repository: mockRepository)

    return OddsListView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

actor MockOddsRepository: OddsRepositoryProtocol {
    func fetchOdds() async throws -> [OddsEvent] {
        return [
            OddsEvent(
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
        ]
    }

    func refreshOdds() async throws -> [OddsEvent] {
        return try await fetchOdds()
    }

    func getCachedOdds() async throws -> [OddsEvent]? {
        return nil
    }
}