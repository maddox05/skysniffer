//
//  OnboardingView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI
import AVKit

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var player: AVPlayer?
    @State private var videoOpacity: Double = 0
    @State private var videoOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var disclaimerOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var notificationObserver: NSObjectProtocol?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Logo at top
                            AppLogo(iconSize: 40, fontSize: 32)
                                .padding(.top, max(geometry.safeAreaInsets.top + 20, 30))
                                .padding(.bottom, 20)

                            // Video player (no phone frame - video has it)
                            if let player = player {
                                VideoPlayer(player: player)
                                    .frame(width: min(geometry.size.width * 0.75, 300),
                                           height: min(geometry.size.height * 0.45, 400))
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 8)
                                    .opacity(videoOpacity)
                                    .offset(y: videoOffset)
                            } else {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(.systemGray6))
                                    .frame(width: min(geometry.size.width * 0.75, 300),
                                           height: min(geometry.size.height * 0.45, 400))
                            }

                            // Spacer equivalent
                            Color.clear.frame(height: 40)

                            // Title
                            VStack(spacing: 12) {
                                Text("SkySniffer")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)

                                Text("AI-Powered Contrail Analysis")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .opacity(titleOpacity)

                            // Disclaimer
                            VStack(spacing: 8) {
                                Text("Educational & Entertainment Use")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundColor(.orange)

                                Text("This app provides AI-powered analysis of atmospheric patterns. Results are for informational purposes and should not be considered definitive scientific conclusions.")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.08))
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .opacity(disclaimerOpacity)

                            // Bottom spacing
                            Color.clear.frame(height: 40)
                        }
                    }

                    // Sticky button at bottom
                    VStack(spacing: 0) {
                        Button {
                            onComplete()
                        } label: {
                            HStack(spacing: 8) {
                                Text("Get Started")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .blue.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom + 20, 30))
                        .background(Color(.systemBackground))
                        .opacity(buttonOpacity)
                    }
                }
            }
        }
        .onAppear {
            setupVideo()

            // Staggered animations for a polished entrance
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                videoOpacity = 1
                videoOffset = 0
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                titleOpacity = 1
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                disclaimerOpacity = 1
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6)) {
                buttonOpacity = 1
            }

            player?.play()
        }
        .onDisappear {
            cleanup()
        }
    }

    private func setupVideo() {
        guard let asset = NSDataAsset(name: "demo_video") else {
            print("Video not found")
            return
        }

        // Write to temp file to create URL for AVPlayer
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("demo_video.mov")
        do {
            try asset.data.write(to: tempURL)
            let playerItem = AVPlayerItem(url: tempURL)
            player = AVPlayer(playerItem: playerItem)
            player?.actionAtItemEnd = .none
            player?.isMuted = true // Mute the audio

            // Loop video
            notificationObserver = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: playerItem,
                queue: .main
            ) { [weak player] _ in
                player?.seek(to: .zero)
                player?.play()
            }
        } catch {
            print("Error writing video to temp file: \(error)")
        }
    }

    private func cleanup() {
        player?.pause()
        player = nil

        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
