import SwiftUI

/// Main tab container for the app
struct TabContainerView: View {
    @State private var selectedTab = 0
    @State private var oddsListViewModel: OddsListViewModel
    @State private var favoritesViewModel: FavoritesViewModel

    init() {
        let repository = DefaultOddsRepository(
            networkService: MockNetworkClient(),
            dataGenerator: MockDataGenerator()
        )
        let favoritesService = DefaultFavoritesService()

        _oddsListViewModel = State(initialValue: OddsListViewModel(repository: repository))
        _favoritesViewModel = State(initialValue: FavoritesViewModel(favoritesService: favoritesService))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Odds List Tab
            NavigationStack {
                OddsListView(viewModel: oddsListViewModel)
            }
            .tabItem {
                Label("Odds", systemImage: "sportscourt")
            }
            .tag(0)

            // Favorites Tab
            NavigationStack {
                FavoritesView(viewModel: favoritesViewModel)
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            .tag(1)

            // Search Tab
            NavigationStack {
                SearchView(viewModel: oddsListViewModel)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(2)
        }
        .onAppear {
            // Load favorites when tab appears
            Task {
                await favoritesViewModel.loadFavorites()
            }
        }
    }
}

// MARK: - Favorites View (Placeholder for Phase 6)
struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.favoriteEvents.isEmpty {
                LoadingView(message: "Loading favorites...")
            } else if viewModel.hasFavorites {
                List(viewModel.favoriteEvents) { event in
                    NavigationLink(destination: OddsDetailView(event: event)) {
                        OddsEventRow(event: event)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    await viewModel.loadFavorites()
                }
            } else {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "heart",
                    description: Text("Add events to favorites to see them here")
                )
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - DefaultFavoritesService Implementation
@MainActor
final class DefaultFavoritesService: FavoritesServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "favorite_events"

    func addFavorite(_ event: OddsEvent) async {
        var favorites = getAllFavoriteIds()
        favorites.insert(event.id)
        saveFavoriteIds(favorites)
    }

    func removeFavorite(_ event: OddsEvent) async {
        var favorites = getAllFavoriteIds()
        favorites.remove(event.id)
        saveFavoriteIds(favorites)
    }

    func isFavorite(_ event: OddsEvent) async -> Bool {
        return getAllFavoriteIds().contains(event.id)
    }

    func getAllFavorites() async -> [OddsEvent] {
        // In a real implementation, you would store full events
        // For now, return empty array - this will be implemented in Phase 6
        return []
    }

    func clearAll() async {
        saveFavoriteIds(Set<String>())
    }

    private func getAllFavoriteIds() -> Set<String> {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let ids = try? JSONDecoder().decode(Set<String>.self, from: data) else {
            return Set<String>()
        }
        return ids
    }

    private func saveFavoriteIds(_ ids: Set<String>) {
        if let data = try? JSONEncoder().encode(ids) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
}

// MARK: - Preview
#Preview {
    TabContainerView()
        .preferredColorScheme(.dark)
}