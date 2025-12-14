# Sports Odds Tracker iOS App

A modern iOS application for tracking sports betting odds across multiple bookmakers, built with Swift 6 and SwiftUI.

## Features

- 🏀 **Multi-Sport Support**: View odds for basketball, football, soccer, and more
- 📊 **Real-time Odds**: Compare odds from multiple bookmakers at a glance
- 🔍 **Search Functionality**: Find specific events or teams quickly
- ❤️ **Favorites Management**: Save and track your favorite events
- ⚙️ **Customizable Settings**: Configure odds format, notifications, and appearance
- 🌙 **Dark Mode**: Full support for light and dark themes

## Technologies

- **Language**: Swift 6 with strict concurrency
- **UI Framework**: SwiftUI
- **Architecture**: MVVM with clean architecture principles
- **Testing**: Swift Testing framework (not XCTest)
- **Data Persistence**: UserDefaults for favorites
- **iOS Version**: 18.0+
- **API**: Mock API implementation for demonstration

## Project Structure

```
FDJ/
├── Core/                    # Core protocols and utilities
│   ├── NetworkServiceProtocol.swift
│   └── OddsRepositoryProtocol.swift
├── Models/                  # Domain models
│   ├── OddsEvent.swift
│   ├── Bookmaker.swift
│   └── Outcome.swift
├── Network/                 # Mock API layer
│   ├── MockNetworkClient.swift
│   └── MockDataGenerator.swift
├── Repository/              # Data layer
│   └── DefaultOddsRepository.swift
├── ViewModels/              # MVVM view models
│   ├── OddsListViewModel.swift
│   ├── FavoritesViewModel.swift
│   └── SearchViewModel.swift
├── Views/                   # SwiftUI views
│   ├── TabContainerView.swift
│   ├── OddsListView.swift
│   ├── SearchView.swift
│   ├── SettingsView.swift
│   └── Components/         # Reusable UI components
├── Services/                # Business logic services
│   └── DefaultFavoritesService.swift
└── Tests/                   # Test suites
    ├── Models/
    ├── ViewModels/
    └── Services/
```

## Architecture

### MVVM Pattern
- **Models**: Represent the data and business logic
- **Views**: SwiftUI views that display the UI
- **ViewModels**: Handle the presentation logic and state

### Clean Architecture Principles
- **Dependency Injection**: All dependencies are injected through protocols
- **Single Responsibility**: Each class has a single purpose
- **Testability**: All components can be easily tested in isolation

### Mock API Implementation
The app uses a mock API that simulates real sports betting data:
- Generates realistic odds data
- Simulates network delays and errors
- No external dependencies or API keys required
- Perfect for demonstrations and testing

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 18.0 SDK
- Swift 6 compiler

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/FDJ.git
   cd FDJ
   ```

2. Open the project in Xcode:
   ```bash
   open FDJ.xcodeproj
   ```

3. Build and run:
   - Select a simulator (iPhone 15 or later recommended)
   - Press `Cmd + R` to build and run

### Running Tests
```bash
# Run all tests
xcodebuild test -scheme FDJ -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -scheme FDJ -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FDJTests
```

## App Screens

### 1. Odds List
- Browse all available sports events
- View best odds across bookmakers
- Live event indicators
- Pull-to-refresh support

### 2. Search
- Search by team name or sport
- Real-time filtering
- Search suggestions

### 3. Favorites
- Quick access to favorite events
- Sort by time, sport, or odds
- Bulk operations (clear all)

### 4. Settings
- Odds format preference (decimal, fractional, American)
- Notification preferences
- Appearance settings
- Data management

## Testing Strategy

### Unit Tests
- 90%+ coverage target for business logic
- Test all view models and services
- Mock external dependencies

### Integration Tests
- Test repository layer with mock API
- Test data persistence layer
- Test service integration

### UI Tests
- Critical user flows
- Navigation patterns
- User interactions

## CI/CD Pipeline

The project includes a GitHub Actions workflow that:
- Builds the project on multiple iOS versions
- Runs all unit and UI tests
- Checks code quality with SwiftLint
- Generates and uploads code coverage
- Creates releases for tagged commits

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Code Style
- Follow Swift API Design Guidelines
- Use Swift 6 strict concurrency features
- Write tests for all new features
- Update documentation as needed

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Swift community for excellent documentation and tools
- Apple for SwiftUI and Combine frameworks
- The sports betting community for domain knowledge

## Contact

Your Name - [@yourusername](https://twitter.com/yourusername)

Project Link: [https://github.com/yourusername/FDJ](https://github.com/yourusername/FDJ)