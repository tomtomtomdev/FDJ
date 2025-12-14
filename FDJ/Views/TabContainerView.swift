import SwiftUI

/// Main tab container for the app
struct TabContainerView: View {
    @State private var selectedTab = 0
    @State private var oddsListViewModel: OddsListViewModel
    @State private var favoritesViewModel: FavoritesViewModel
    private let favoritesService: FavoritesServiceProtocol

    init() {
        let repository = DefaultOddsRepository(
            networkService: MockNetworkClient(),
            dataGenerator: MockDataGenerator()
        )
        let favoritesService = DefaultFavoritesService()

        _oddsListViewModel = State(initialValue: OddsListViewModel(repository: repository))
        _favoritesViewModel = State(initialValue: FavoritesViewModel(favoritesService: favoritesService))
        self.favoritesService = favoritesService
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Odds List Tab
            NavigationStack {
                OddsListView(viewModel: oddsListViewModel, favoritesService: favoritesService)
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
                SearchView(viewModel: oddsListViewModel, favoritesService: favoritesService)
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(2)

            // Settings Tab
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .onAppear {
            // Load favorites when tab appears
            Task {
                await favoritesViewModel.loadFavorites()
            }
        }
    }
}

// MARK: - Favorites View
struct FavoritesView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    @State private var selectedSortOption: SortOption = .time
    @State private var showingClearAlert = false

    enum SortOption: String, CaseIterable {
        case time = "Time"
        case sport = "Sport"
        case odds = "Best Odds"
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.favoriteEvents.isEmpty {
                LoadingView(message: "Loading favorites...")
            } else if viewModel.hasFavorites {
                VStack(spacing: 0) {
                    // Sort and filter controls
                    sortControls

                    // Favorites list
                    List(sortedFavorites) { event in
                        NavigationLink(destination: OddsDetailView(event: event)) {
                            FavoriteEventRow(
                                event: event,
                                onRemove: {
                                    Task {
                                        await viewModel.removeFavorite(event)
                                    }
                                }
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await viewModel.loadFavorites()
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "heart",
                    description: Text("Tap the heart icon on any event to add it to favorites")
                )
            }
        }
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if viewModel.hasFavorites {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        showingClearAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .alert("Clear All Favorites", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                Task {
                    await viewModel.clearAllFavorites()
                }
            }
        }
    }

    @ViewBuilder
    private var sortControls: some View {
        HStack {
            Text("Sort by:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Sort", selection: $selectedSortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }

    private var sortedFavorites: [OddsEvent] {
        let favorites = viewModel.favoriteEvents

        switch selectedSortOption {
        case .time:
            return favorites.sorted { $0.commenceTime < $1.commenceTime }
        case .sport:
            return favorites.sorted { $0.sport < $1.sport }
        case .odds:
            return favorites.sorted { event1, event2 in
                let best1 = event1.bestOddsAcrossBookmakers?.first?.price ?? 0
                let best2 = event2.bestOddsAcrossBookmakers?.first?.price ?? 0
                return best1 > best2
            }
        }
    }
}

// MARK: - Favorite Event Row Component
struct FavoriteEventRow: View {
    let event: OddsEvent
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                HStack {
                    Text(event.sportDisplay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Capsule())

                    Spacer()

                    if event.isLive {
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .clipShape(Capsule())
                    } else {
                        Text(event.timeUntilEvent)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}


// MARK: - Preview
#Preview {
    TabContainerView()
        .preferredColorScheme(.dark)
}