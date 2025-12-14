import SwiftUI

/// Main view displaying a list of sports odds events
struct OddsListView: View {
    @State private var viewModel: OddsListViewModel
    @State private var selectedEvent: OddsEvent?
    @State private var showingSearch = false
    private let favoritesService: FavoritesServiceProtocol

    init(viewModel: OddsListViewModel, favoritesService: FavoritesServiceProtocol) {
        _viewModel = State(initialValue: viewModel)
        self.favoritesService = favoritesService
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
                SearchView(viewModel: viewModel, favoritesService: favoritesService)
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
                OddsEventRow(
                    event: event,
                    onFavoriteToggle: { event in
                        Task {
                            if await favoritesService.isFavorite(event) {
                                await favoritesService.removeFavorite(event)
                            } else {
                                await favoritesService.addFavorite(event)
                            }
                        }
                    }
                )
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Preview
#Preview {
    let mockRepository = MockOddsRepository()
    let viewModel = OddsListViewModel(repository: mockRepository)
    let favoritesService = MockFavoritesService()

    OddsListView(viewModel: viewModel, favoritesService: favoritesService)
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

// Mock FavoritesService for previews
actor MockFavoritesService: FavoritesServiceProtocol {
    private var favorites: Set<String> = []

    func addFavorite(_ event: OddsEvent) async {
        favorites.insert(event.id)
    }

    func removeFavorite(_ event: OddsEvent) async {
        favorites.remove(event.id)
    }

    func isFavorite(_ event: OddsEvent) async -> Bool {
        return favorites.contains(event.id)
    }

    func getAllFavorites() async -> [OddsEvent] {
        return []
    }

    func clearAll() async {
        favorites.removeAll()
    }
}