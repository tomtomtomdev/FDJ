import SwiftUI

/// Error display view with retry functionality
struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.headline)

            Text(error.localizedDescription)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Compact error view for inline display
struct CompactErrorView: View {
    let error: Error
    let retryAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text("Error")
                    .font(.headline)
                    .foregroundColor(.red)

                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            Button("Retry", action: retryAction)
                .font(.caption)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Network specific error view
struct NetworkErrorView: View {
    let error: Error
    let retryAction: () -> Void
    @State private var isRetrying = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Connection Error")
                .font(.headline)

            Text("Unable to load data. Please check your internet connection and try again.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                isRetrying = true
                retryAction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isRetrying = false
                }
            }) {
                HStack {
                    if isRetrying {
                        CompactLoadingView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                    Text(isRetrying ? "Retrying..." : "Retry")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRetrying)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Empty state view when no data is available
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let description: String
    let action: (() -> Void)?
    let actionTitle: String?

    init(
        systemImage: String,
        title: String,
        description: String,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.action = action
        self.actionTitle = actionTitle
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let action = action, let actionTitle = actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview("Standard Error") {
    ErrorView(
        error: NetworkError.requestFailed,
        retryAction: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Network Error") {
    NetworkErrorView(
        error: NetworkError.requestFailed,
        retryAction: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Compact Error") {
    CompactErrorView(
        error: NetworkError.requestFailed,
        retryAction: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    EmptyStateView(
        systemImage: "tray",
        title: "No Data Available",
        description: "There are currently no events to display.",
        actionTitle: "Refresh"
    )
    .preferredColorScheme(.dark)
}