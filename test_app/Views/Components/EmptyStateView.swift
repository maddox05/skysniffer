//
//  EmptyStateView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Paper airplane with subtle animation
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: 140, height: 140)

                Image(systemName: "paperplane.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees(45))
                    .offset(x: isAnimating ? 2 : -2, y: isAnimating ? -2 : 2)
            }
            .padding(.bottom, 32)

            Text("No Scans Yet")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.bottom, 8)

            Text("Tap the camera button to get started")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Helpful tips
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text("Take a photo of the sky showing contrails from aircraft")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text("Or select an existing photo from your library")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text("AI will analyze persistence patterns and climate impact")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 32)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    EmptyStateView()
}
