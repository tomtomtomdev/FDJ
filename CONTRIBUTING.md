# Contributing to Sports Odds Tracker

Thank you for your interest in contributing to the Sports Odds Tracker iOS app! This guide will help you get started.

## Code of Conduct

By participating in this project, you agree to abide by our code of conduct:
- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Maintain a professional and friendly atmosphere

## Development Workflow

### 1. Setup Development Environment

1. **Prerequisites**:
   - macOS latest version
   - Xcode 15.0 or later
   - iOS 18.0 SDK
   - Swift 6 compiler

2. **Clone and Setup**:
   ```bash
   git clone https://github.com/yourusername/FDJ.git
   cd FDJ
   ```

3. **Open in Xcode**:
   ```bash
   open FDJ.xcodeproj
   ```

### 2. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Or for a bug fix:
```bash
git checkout -b fix/issue-number-description
```

### 3. Make Your Changes

#### Swift Style Guide

Follow these guidelines for consistent code style:

1. **Naming**:
   - Use descriptive names that explain the purpose
   - Follow Swift API Design Guidelines
   - Use camelCase for variables and functions
   - Use PascalCase for types (classes, structs, enums)

2. **Code Organization**:
   - Group related functionality
   - Use extensions for organization
   - Mark `private`/internal appropriately
   - Add comments for complex logic

3. **Swift 6 Concurrency**:
   - Use `@MainActor` for UI-related code
   - Make types `Sendable` where appropriate
   - Use actors for data synchronization
   - Avoid data races

4. **Testing**:
   - Write tests before implementation (TDD)
   - Test edge cases and error conditions
   - Use descriptive test names
   - Mock external dependencies

#### Example Code Style

```swift
// Good - descriptive name, single responsibility
actor DefaultFavoritesService: FavoritesServiceProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func addFavorite(_ event: OddsEvent) async {
        // Implementation
    }
}

// Good - clear test name
@Test("FavoritesService should add event to favorites")
func testAddFavorite() async {
    // Given
    let service = DefaultFavoritesService()
    let event = mockEvent

    // When
    await service.addFavorite(event)

    // Then
    let isFavorite = await service.isFavorite(event)
    #expect(isFavorite == true)
}
```

### 4. Test Your Changes

1. **Run Unit Tests**:
   ```bash
   xcodebuild test -scheme FDJ -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

2. **Run UI Tests**:
   ```bash
   xcodebuild test -scheme FDJ -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:FDJUITests
   ```

3. **Check Code Coverage**:
   - Maintain 85%+ coverage for new code
   - Focus on testing business logic

4. **Manual Testing**:
   - Test the UI changes on device/simulator
   - Verify accessibility features
   - Check both light and dark modes

### 5. Commit Your Changes

Write clear commit messages:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

Example:
```
feat(favorites): Add bulk remove functionality

- Add swipe-to-delete on favorites list
- Add confirmation dialog for bulk operations
- Update tests for new functionality

Closes #123
```

### 6. Create a Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**:
   - Use the GitHub UI to create a PR
   - Link to any relevant issues
   - Provide a clear description of changes
   - Include screenshots for UI changes

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] All tests pass
   - [ ] Manual testing completed
   - [ ] Accessibility tested

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   ```

## Project Structure

### Architecture Decisions

1. **MVVM with Clean Architecture**:
   - Separation of concerns
   - Testable code
   - Clear data flow

2. **Mock API Implementation**:
   - No external dependencies
   - Consistent test data
   - Offline development

3. **Swift 6 Concurrency**:
   - Type-safe concurrency
   - Actor isolation
   - Sendable protocols

### Adding New Features

1. **Models**:
   - Add to `Models/` directory
   - Make them `Codable`, `Sendable`, and `Equatable`
   - Write tests in `Tests/Models/`

2. **ViewModels**:
   - Add to `ViewModels/` directory
   - Use `@Observable` macro
   - Write tests in `Tests/ViewModels/`

3. **Views**:
   - Add to `Views/` directory
   - Use SwiftUI
   - Follow navigation patterns
   - Create reusable components

4. **Services**:
   - Add to `Services/` directory
   - Create protocol first
   - Write tests in `Tests/Services/`

## Testing Guidelines

### Test-Driven Development (TDD)

1. **Red**: Write a failing test
2. **Green**: Write minimal code to pass
3. **Refactor**: Improve the code

### Test Structure

```swift
struct MyViewModelTests {
    @Test("ViewModel should initialize with correct state")
    func testInitialState() async {
        // Given
        let mockService = MockService()

        // When
        let viewModel = MyViewModel(service: mockService)

        // Then
        #expect(viewModel.isLoading == false)
        #expect(viewModel.items.isEmpty == true)
    }
}
```

### What to Test

1. **Unit Tests**:
   - Business logic
   - Data transformations
   - State management
   - Error handling

2. **Integration Tests**:
   - Service interactions
   - Data persistence
   - API integration (mock)

3. **UI Tests**:
   - Critical user flows
   - Navigation
   - Form validation
   - Error states

## Release Process

1. Update version in Xcode
2. Update CHANGELOG.md
3. Create release tag
4. GitHub Actions will build and release

## Getting Help

- Create an issue for bugs or feature requests
- Join our discussions for questions
- Check existing documentation

## License

By contributing, you agree that your contributions will be licensed under the MIT License.