//
//  ResultView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI

struct ResultView: View {
    let result: DetectionResult
    let image: UIImage
    let onDone: () -> Void
    @State private var imageOpacity: Double = 0
    @State private var statusCardOpacity: Double = 0
    @State private var statsOpacity: Double = 0
    @State private var detailsOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(spacing: 24) {
                    // Hero image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .opacity(imageOpacity)

                    if !result.isValidImage {
                        // Show invalid image message
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.orange)

                            Text("Not a Sky Image")
                                .font(.custom("EBGaramond-SemiBold", size: 24))
                                .foregroundColor(.primary)

                            Text(result.explanation)
                                .font(.custom("EBGaramond-Regular", size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Text("Please upload an image of the sky with visible contrails or cloud formations.")
                                .font(.custom("EBGaramond-Regular", size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // Show normal analysis results
                        VStack(spacing: 16) {
                            // Main status card
                            VStack(spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: detectionIcon)
                                        .font(.system(size: 24))
                                        .foregroundColor(detectionColor)

                                    Text(detectionMessage)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(detectionColor)

                                    Spacer()
                                }

                                HStack {
                                    Text("Persistence Level")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)

                                    Spacer()

                                    Text(result.riskLevel)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(persistenceLevelColor)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(detectionColor.opacity(0.05))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(detectionColor.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            .opacity(statusCardOpacity)

                            // Stats cards
                            HStack(spacing: 12) {
                                StatCard(
                                    icon: "chart.bar.fill",
                                    title: "Confidence",
                                    value: "\(Int(result.confidenceScore * 100))%",
                                    color: .blue
                                )

                                StatCard(
                                    icon: "list.bullet.rectangle",
                                    title: "Patterns",
                                    value: "\(result.detectedPatterns.count)",
                                    color: .purple
                                )
                            }
                            .padding(.horizontal, 20)
                            .opacity(statsOpacity)

                            // Patterns section
                            VStack(spacing: 16) {
                                if !result.detectedPatterns.isEmpty {
                                    InfoCard(title: "Detected Patterns", icon: "list.bullet.rectangle") {
                                        VStack(alignment: .leading, spacing: 8) {
                                            ForEach(result.detectedPatterns, id: \.self) { pattern in
                                                HStack(spacing: 8) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.blue)
                                                    Text(pattern)
                                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                                }
                                            }
                                        }
                                    }
                                }

                                // Atmospheric conditions
                                InfoCard(title: "Atmospheric Conditions", icon: "cloud.fill") {
                                    Text(result.atmosphericConditions)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                }

                                // Analysis
                                InfoCard(title: "AI Analysis", icon: "brain.head.profile") {
                                    Text(result.explanation)
                                        .font(.system(size: 14, weight: .regular, design: .rounded))
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                }
                            }
                            .opacity(detailsOpacity)
                        }
                    }
                }
                .padding(.bottom, 20)
            }

            // Sticky button at bottom
            VStack(spacing: 0) {
                Divider()

                Button {
                    onDone()
                } label: {
                    HStack(spacing: 8) {
                        Text("Done")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            // Staggered animations for polished entrance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                imageOpacity = 1
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                statusCardOpacity = 1
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                statsOpacity = 1
            }

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                detailsOpacity = 1
            }
        }
    }

    private var persistenceLevelColor: Color {
        switch result.riskLevel.lowercased() {
        case "low":
            return .green
        case "medium":
            return .blue
        case "high":
            return .indigo
        case "critical":
            return .purple
        default:
            return .gray
        }
    }

    private var detectionMessage: String {
        switch result.riskLevel.lowercased() {
        case "low":
            return "Normal Contrails"
        case "medium":
            return "Unusual Contrails Detected"
        case "high":
            return "Highly Unusual Contrails"
        case "critical":
            return "Possible Chemtrail Detected"
        default:
            return "Normal Contrails"
        }
    }

    private var detectionIcon: String {
        switch result.riskLevel.lowercased() {
        case "low":
            return "checkmark.circle.fill"
        case "medium":
            return "exclamationmark.circle.fill"
        case "high":
            return "exclamationmark.triangle.fill"
        case "critical":
            return "exclamationmark.triangle.fill"
        default:
            return "checkmark.circle.fill"
        }
    }

    private var detectionColor: Color {
        switch result.riskLevel.lowercased() {
        case "low":
            return .green
        case "medium":
            return .orange
        case "high":
            return .red
        case "critical":
            return Color(red: 0.7, green: 0, blue: 0) // Dark red
        default:
            return .green
        }
    }
}

// MARK: - Helper Components

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal, 20)
    }
}
