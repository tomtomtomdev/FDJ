import SwiftUI

/// Loading indicator view with optional message
struct LoadingView: View {
    let message: String?
    @State private var isAnimating = false

    init(message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 8)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(
                            lineWidth: 8,
                            lineCap: .round
                        )
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Variations

struct CompactLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                Color.blue,
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )
            .frame(width: 20, height: 20)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct FullScreenLoadingView: View {
    let message: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LoadingView(message: message)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
            }
        }
    }
}

// MARK: - Preview
#Preview("Standard Loading") {
    LoadingView(message: "Loading data...")
        .preferredColorScheme(.dark)
}

#Preview("Compact Loading") {
    HStack {
        Text("Loading")
        CompactLoadingView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Full Screen Loading") {
    FullScreenLoadingView(message: "Please wait...")
        .preferredColorScheme(.dark)
}