import SwiftUI

/// Search view for finding odds events
struct SearchView: View {
    @State private var searchViewModel = SearchViewModel()
    @State private var oddsListViewModel: OddsListViewModel
    @Environment(\.dismiss) private var dismiss
    private let favoritesService: FavoritesServiceProtocol

    init(viewModel: OddsListViewModel, favoritesService: FavoritesServiceProtocol) {
        self._oddsListViewModel = State(initialValue: viewModel)
        self.favoritesService = favoritesService
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Search suggestions
                if searchViewModel.hasSearchTerm && !searchViewModel.isSearching {
                    searchSuggestions
                }

                // Search results or loading
                if searchViewModel.isSearching {
                    LoadingView(message: "Searching...")
                } else if searchViewModel.hasResults {
                    searchResults
                } else if searchViewModel.hasSearchTerm && !searchViewModel.hasResults {
                    ContentUnavailableView.search(text: searchViewModel.searchText)
                } else {
                    searchPrompt
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            searchViewModel.updateOdds(oddsListViewModel.odds)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search teams or sports...", text: $searchViewModel.searchText)
                .textFieldStyle(.plain)
                .onSubmit {
                    dismissKeyboard()
                }

            if !searchViewModel.searchText.isEmpty {
                Button {
                    searchViewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var searchSuggestions: some View {
        let suggestions = searchViewModel.searchSuggestions(for: searchViewModel.searchText)

        if !suggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(suggestion) {
                            searchViewModel.searchText = suggestion
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var searchResults: some View {
        List(searchViewModel.filteredOdds) { event in
            NavigationLink(destination: OddsDetailView(event: event)) {
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

    @ViewBuilder
    private var searchPrompt: some View {
        ContentUnavailableView(
            "Search for Events",
            systemImage: "magnifyingglass",
            description: Text("Enter team names or sports to find events")
        )
    }
}

// MARK: - DismissKeyboard Extension
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    let mockRepository = MockOddsRepositoryForSearch()
    let viewModel = OddsListViewModel(repository: mockRepository)
    let favoritesService = MockFavoritesServiceForSearch()

    SearchView(viewModel: viewModel, favoritesService: favoritesService)
        .preferredColorScheme(.dark)
}

// Mock dependencies for previews
actor MockOddsRepositoryForSearch: OddsRepositoryProtocol {
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

actor MockFavoritesServiceForSearch: FavoritesServiceProtocol {
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