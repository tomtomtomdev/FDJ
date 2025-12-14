# Architecture Documentation

## Overview

The Sports Odds Tracker iOS app follows a clean architecture pattern with MVVM (Model-View-ViewModel) presentation layer. This architecture promotes testability, maintainability, and scalability.

## High-Level Architecture

```
┌─────────────────────────────────────────────────┐
│                 UI Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │   Views     │  │ Components  │  │Navigation│ │
│  │  (SwiftUI)  │  │ (SwiftUI)   │  │(SwiftUI) │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│             Presentation Layer                  │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │ ViewModels  │  │ObservableObj│  │ Bindings │ │
│  │  (Swift 6)  │  │    (Swift)  │  │(Combine) │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│              Business Logic Layer               │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │  Services   │  │Repositories │  │Use Cases │ │
│  │  (Actors)   │  │ (Protocols) │  │(Future)  │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                Data Layer                        │
│  ┌─────────────┐  ┌─────────────┐  ┌──────────┐ │
│  │Mock Network │  │UserDefaults │  │Models    │ │
│  │   Client    │  │(Persistence)│  │(Codable) │ │
│  └─────────────┘  └─────────────┘  └──────────┘ │
└─────────────────────────────────────────────────┘
```

## Core Principles

### 1. Dependency Inversion
All high-level modules depend on abstractions (protocols), not concretions.

```swift
// Protocol defines the contract
protocol OddsRepositoryProtocol: Sendable {
    func fetchOdds() async throws -> [OddsEvent]
    func refreshOdds() async throws -> [OddsEvent]
}

// Concrete implementation
actor DefaultOddsRepository: OddsRepositoryProtocol {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
}
```

### 2. Single Responsibility
Each class has one reason to change.

```swift
// ViewModel only handles presentation logic
@Observable
class OddsListViewModel {
    private let repository: OddsRepositoryProtocol

    func loadOdds() async {
        // Only presentation logic, no business rules
    }
}

// Repository only handles data access
actor DefaultOddsRepository: OddsRepositoryProtocol {
    // Only data access, no presentation logic
}
```

### 3. Actor Isolation
Data races are prevented through Swift 6 actors.

```swift
actor FavoritesStore {
    private var favorites: Set<String> = []

    func add(_ id: String) {
        favorites.insert(id)
    }

    func contains(_ id: String) -> Bool {
        favorites.contains(id)
    }
}
```

## Layer Details

### UI Layer (SwiftUI)

**Responsibilities**:
- Display data to users
- Capture user interactions
- Delegate business logic to ViewModels

**Key Components**:
- `TabContainerView`: Main navigation container
- `OddsListView`: List of odds events
- `SearchView`: Search functionality
- `SettingsView`: App configuration
- `OddsEventRow`: Reusable row component

**Example**:
```swift
struct OddsListView: View {
    @State private var viewModel: OddsListViewModel
    private let favoritesService: FavoritesServiceProtocol

    var body: some View {
        // UI declarations only
        List(viewModel.filteredOdds) { event in
            OddsEventRow(event: event)
        }
    }
}
```

### Presentation Layer (ViewModels)

**Responsibilities**:
- Transform data for presentation
- Handle UI state
- Coordinate with services

**Key Patterns**:
- `@Observable` macro for state management
- `@MainActor` for UI-related ViewModels
- Async/await for asynchronous operations

**Example**:
```swift
@Observable
@MainActor
class OddsListViewModel {
    private let repository: OddsRepositoryProtocol

    var odds: [OddsEvent] = []
    var isLoading = false
    var error: Error?

    func loadOdds() async {
        isLoading = true
        defer { isLoading = false }

        do {
            odds = try await repository.fetchOdds()
        } catch {
            self.error = error
        }
    }
}
```

### Business Logic Layer (Services)

**Responsibilities**:
- Implement business rules
- Coordinate between repositories
- Handle complex operations

**Key Patterns**:
- Actor isolation for data safety
- Protocol-oriented design
- Dependency injection

**Example**:
```swift
actor DefaultFavoritesService: FavoritesServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let store = FavoritesStore()

    func addFavorite(_ event: OddsEvent) async {
        await store.add(event.id)
        saveToUserDefaults(event)
    }
}
```

### Data Layer (Repositories & Models)

**Responsibilities**:
- Data persistence
- Network communication
- Data transformation

**Key Components**:
- Mock Network Client (simulates API)
- UserDefaults for favorites
- Codable models for serialization

**Example**:
```swift
actor MockNetworkClient: NetworkServiceProtocol {
    func request<T: Codable>(_ endpoint: String) async throws -> T {
        // Simulate network delay
        try await Task.sleep(for: .seconds(1))

        // Return mock data
        return try MockDataGenerator.generate(type: T.self)
    }
}
```

## Data Flow

### 1. Loading Data
```
View → ViewModel → Repository → Network/Data Store → Model → ViewModel → View
```

### 2. User Action
```
User Interaction → View → ViewModel → Service → Repository → Persistence
```

### 3. State Updates
```
Data Change → Repository → ViewModel → @Observable → View Update
```

## Mock API Architecture

The app uses a mock API instead of real external APIs for:
- **Reliability**: No network dependencies
- **Testability**: Consistent test data
- **Cost**: No API fees
- **Speed**: Faster development

### Mock Data Generation

```swift
actor MockDataGenerator {
    static func generateOddsEvents() -> [OddsEvent] {
        return [
            OddsEvent(
                id: "basketball_1",
                sport: "basketball",
                homeTeam: "Lakers",
                awayTeam: "Warriors",
                commenceTime: Date().addingTimeInterval(3600),
                bookmakers: generateBookmakers()
            )
        ]
    }
}
```

## Testing Architecture

### Unit Tests
- Test each layer in isolation
- Use mock objects for dependencies
- Focus on business logic

### Integration Tests
- Test layer interactions
- Use real dependencies where safe
- Test data flow

### UI Tests
- Test user workflows
- Verify UI state changes
- Check navigation patterns

## Concurrency Model

Swift 6 strict concurrency is used throughout:

### Actor Usage
- `@MainActor` for ViewModels
- Custom actors for data stores
- Sendable protocols for data transfer

### Example
```swift
@MainActor
class MyViewModel: ObservableObject {
    // All properties are main-actor isolated
}

actor DataStore {
    // Data is protected from concurrent access
}
```

## Benefits of This Architecture

1. **Testability**: Each component can be tested independently
2. **Maintainability**: Clear separation of concerns
3. **Scalability**: Easy to add new features
4. **Flexibility**: Can swap implementations easily
5. **Type Safety**: Swift 6 prevents data races
6. **Performance**: Efficient memory usage and minimal dependencies

## Future Enhancements

1. **Real API Integration**: Swap mock client with real API client
2. **Offline Support**: Add Core Data for robust offline storage
3. **Caching Layer**: Implement intelligent caching strategies
4. **Authentication**: Add user authentication
5. **Analytics**: Integrate analytics services

## Conclusion

This architecture provides a solid foundation for a scalable, maintainable iOS app. The clean separation of concerns, combined with Swift 6's safety features, ensures the codebase remains robust and easy to work with as the app grows.