//
//  ScanRowView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct ScanRowView: View {
    let scan: ScanResult

    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let imageData = scan.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.5))
                            .font(.system(size: 24))
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                // Status and risk badge
                HStack(spacing: 8) {
                    if !scan.isValidImage {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text("Invalid Image")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(.orange)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: scan.isChemTrail ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text(scan.isChemTrail ? "Chemtrail Detected" : "Normal Contrail")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(scan.isChemTrail ? .red : .green)
                    }

                    Spacer()

                    if scan.isValidImage {
                        Text(scan.riskLevel)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(riskLevelColor(for: scan.riskLevel))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }

                // Date
                Text(scan.timestamp, style: .date)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)

                // Stats
                if scan.isValidImage {
                    HStack(spacing: 12) {
                        Label("\(Int(scan.confidenceScore * 100))%", systemImage: "chart.bar.fill")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.blue)

                        Label("\(scan.detectedPatterns.count)", systemImage: "list.bullet.rectangle")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.purple)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func riskLevelColor(for level: String) -> Color {
        switch level.lowercased() {
        case "low":
            return .green
        case "medium":
            return .orange
        case "high":
            return .red
        case "critical":
            return Color(red: 0.7, green: 0, blue: 0)
        default:
            return .gray
        }
    }
}
