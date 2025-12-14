import SwiftUI

/// Settings view for app configuration
struct SettingsView: View {
    @State private var selectedOddsFormat: OddsFormat = .decimal
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showingAbout = false

    enum OddsFormat: String, CaseIterable {
        case decimal = "Decimal"
        case fractional = "Fractional"
        case american = "American"

        var example: String {
            switch self {
            case .decimal:
                return "2.50"
            case .fractional:
                return "6/4"
            case .american:
                return "+150"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Odds Display Section
                Section("Odds Display") {
                    Picker("Format", selection: $selectedOddsFormat) {
                        ForEach(OddsFormat.allCases, id: \.self) { format in
                            HStack {
                                Text(format.rawValue)
                                    .font(.body)
                                Spacer()
                                Text(format.example)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(format)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Notifications Section
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)

                    if notificationsEnabled {
                        NavigationLink("Notification Settings") {
                            NotificationSettingsView()
                        }
                    }
                }

                // Appearance Section
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                        .onChange(of: darkModeEnabled) { _, newValue in
                            // Apply dark mode setting
                            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                            windowScene.windows.forEach { window in
                                window.overrideUserInterfaceStyle = newValue ? .dark : .light
                            }
                        }
                }

                // Data Section
                Section("Data Management") {
                    Button("Clear Cache") {
                        clearCache()
                    }
                    .foregroundStyle(.red)

                    Button("Reset All Settings") {
                        resetSettings()
                    }
                    .foregroundStyle(.red)
                }

                // About Section
                Section("About") {
                    Button("About This App") {
                        showingAbout = true
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion ?? "1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }

    private func clearCache() {
        Task {
            // Clear odds cache
            UserDefaults.standard.removeObject(forKey: "cached_odds")
            UserDefaults.standard.removeObject(forKey: "last_cache_update")

            // Show alert
            await showAlert(title: "Cache Cleared", message: "The cache has been successfully cleared.")
        }
    }

    private func resetSettings() {
        Task {
            // Reset all settings to defaults
            UserDefaults.standard.removeObject(forKey: "odds_format")
            UserDefaults.standard.removeObject(forKey: "notifications_enabled")
            UserDefaults.standard.removeObject(forKey: "dark_mode_enabled")

            // Update UI
            selectedOddsFormat = .decimal
            notificationsEnabled = true
            darkModeEnabled = false

            // Show alert
            await showAlert(title: "Settings Reset", message: "All settings have been reset to their defaults.")
        }
    }

    @MainActor
    private func showAlert(title: String, message: String) async {
        // In a real app, you'd implement a proper alert system
        print("Alert: \(title) - \(message)")
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @State private var preMatchEnabled = true
    @State private var liveUpdatesEnabled = true
    @State private var priceChangeAlerts = false
    @State private var minutesBefore = 30

    var body: some View {
        Form {
            Section("Match Notifications") {
                Toggle("Pre-match Reminders", isOn: $preMatchEnabled)

                if preMatchEnabled {
                    HStack {
                        Text("Remind Me")
                        Spacer()
                        Picker("Minutes Before", selection: $minutesBefore) {
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("1 hour").tag(60)
                            Text("2 hours").tag(120)
                        }
                        .pickerStyle(.segmented)
                    }
                }
            }

            Section("Live Notifications") {
                Toggle("Live Score Updates", isOn: $liveUpdatesEnabled)
                Toggle("Price Change Alerts", isOn: $priceChangeAlerts)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App icon placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.blue.gradient)
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                    }

                Text("Sports Odds Tracker")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Version \(Bundle.main.appVersion ?? "1.0.0")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("A modern iOS app for tracking sports odds across multiple bookmakers.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Spacer()

                VStack(spacing: 10) {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
                .font(.subheadline)
            }
            .padding()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}