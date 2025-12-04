//
//  SettingsView.swift
//  test_app
//
//  Created by Claude on 12/3/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingAbout = false
    @State private var showingShareSheet = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        NavigationStack {
            List {
                // App Info Section
                Section {
                    HStack {
                        Image(colorScheme == .dark ? "App Icon White" : "App Icon Black")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("SkySniffer")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.leading, 12)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("App Information")
                }

                // About Section
                Section {
                    Button {
                        showingAbout = true
                    } label: {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "About SkySniffer",
                            color: .blue
                        )
                    }

                    Link(destination: URL(string: "https://maddox05.github.io/skysniffer/privacy.html")!) {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            color: .green,
                            showChevron: true
                        )
                    }

                    Link(destination: URL(string: "https://maddox05.github.io/skysniffer/")!) {
                        SettingsRow(
                            icon: "lifepreserver.fill",
                            title: "Support & Help",
                            color: .orange,
                            showChevron: true
                        )
                    }

                    Link(destination: URL(string: "mailto:schmidlkoferbusiness@gmail.com")!) {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Contact Us",
                            color: .purple,
                            showChevron: true
                        )
                    }
                } header: {
                    Text("Information")
                }

                // Actions Section
                Section {
                    Button {
                        showingShareSheet = true
                    } label: {
                        SettingsRow(
                            icon: "square.and.arrow.up.fill",
                            title: "Share SkySniffer",
                            color: .indigo
                        )
                    }

                    Link(destination: URL(string: "https://apps.apple.com/app/id6756071974")!) {
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate on App Store",
                            color: .yellow,
                            showChevron: true
                        )
                    }
                } header: {
                    Text("Actions")
                }

                // Legal Section
                Section {
                    Text("SkySniffer uses AI to analyze contrail patterns for educational purposes. AI-generated results are not scientific facts or definitive conclusions.")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } header: {
                    Text("Disclaimer")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(
                    activityItems: [
                        "Check out SkySniffer - AI-powered contrail analysis! Analyze contrail patterns and learn about atmospheric phenomena.",
                        URL(string: "https://apps.apple.com/app/id6756071974")!
                    ]
                )
            }
        }
    }

}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(title)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.primary)

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(colorScheme == .dark ? "App Icon White" : "App Icon Black")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        .padding(.top, 32)

                    VStack(spacing: 8) {
                        Text("SkySniffer")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("AI-Powered Contrail Analysis")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))

                        Text("SkySniffer uses advanced AI technology to analyze contrail patterns, persistence levels, and atmospheric conditions in your sky photos. Learn about aviation weather phenomena and contrail formation through AI-powered scientific analysis.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)

                        Text("Features")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(icon: "brain.head.profile", text: "AI-powered image analysis using GPT-4 Vision")
                            FeatureRow(icon: "chart.bar.fill", text: "Detailed pattern detection and confidence scores")
                            FeatureRow(icon: "clock.arrow.circlepath", text: "Scan history with local storage")
                            FeatureRow(icon: "lock.shield.fill", text: "Privacy-focused: all data stored locally")
                        }

                        Text("Important")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(.top, 8)

                        Text("This app is designed for educational purposes. All analysis results are AI-generated and are not scientific facts. Use this app to learn about contrails and atmospheric phenomena.")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SettingsView()
}
