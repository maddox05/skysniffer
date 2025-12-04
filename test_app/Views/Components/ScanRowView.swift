//
//  ScanRowView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct ScanRowView: View {
    let scan: ScanResult

    private var persistenceHelper: PersistenceLevelHelper {
        PersistenceLevelHelper(level: scan.persistenceLevel)
    }

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
                            Image(systemName: persistenceHelper.icon)
                                .font(.system(size: 12))
                            Text(persistenceHelper.shortMessage)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(persistenceHelper.color)
                    }

                    Spacer()

                    if scan.isValidImage {
                        Text(scan.persistenceLevel)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(persistenceHelper.color)
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
}
