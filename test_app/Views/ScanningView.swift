//
//  ScanningView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI

struct ScanningView: View {
    let image: UIImage?
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.98
    @State private var pulseScale: CGFloat = 1.0
    @State private var scanLineOffset: CGFloat = -200

    var body: some View {
        ZStack {
            // Clean white background
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Image being analyzed
                if let image = image {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 350)
                            .clipped()
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                            .overlay(
                                // Scanning line animation
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0),
                                                Color.blue.opacity(0.3),
                                                Color.blue.opacity(0)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 60)
                                    .offset(y: scanLineOffset)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                } else {
                    // Fallback if no image
                    Image(systemName: "photo")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                        .opacity(opacity)
                }

                Spacer()

                // Clean status text with pulsing animation
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)

                        Circle()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseScale)

                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(.blue)
                    }

                    Text("Analyzing Contrails")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
                .opacity(opacity)

                Spacer()
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            // Entrance animation
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1
                scale = 1
            }

            // Pulsing animation for loading indicator
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.2
            }

            // Scanning line animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                scanLineOffset = 200
            }
        }
    }
}

#Preview {
    ScanningView(image: UIImage(systemName: "photo"))
}
