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
    @State private var videoScale: CGFloat = 0.7
    @State private var videoRotation: Double = -15
    @State private var titleOpacity: Double = 0
    @State private var disclaimerOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    @State private var notificationObserver: NSObjectProtocol?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            // Top padding
                            Color.clear.frame(height: 20)

                            // Video player (no phone frame - video has it)
                            if let player = player {
                                VideoPlayer(player: player)
                                    .aspectRatio(1206/2622, contentMode: .fit)
                                    .frame(width: min(geometry.size.width * 0.65, 300))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(Color.gray.opacity(0.6), lineWidth: 2.5)
                                    )
                                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 8)
                                    .scaleEffect(videoScale)
                                    .rotation3DEffect(
                                        .degrees(videoRotation),
                                        axis: (x: 1, y: 0, z: 0),
                                        perspective: 0.5
                                    )
                                    .opacity(videoOpacity)
                                    .offset(y: videoOffset)
                            } else {
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(.systemGray6))
                                    .aspectRatio(1206/2622, contentMode: .fit)
                                    .frame(width: min(geometry.size.width * 0.65, 300))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .strokeBorder(Color.gray.opacity(0.6), lineWidth: 2.5)
                                    )
                            }

                        }
                    }

                    // Sticky button at bottom
                    VStack(spacing: 0) {
                        // Title
                        VStack(spacing: 8) {
                            Text("SkySniffer")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)

                            Text("AI-Powered Contrail Analysis")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                        .opacity(titleOpacity)

                        // Educational disclaimer - REQUIRED for App Store
                        Text("AI-generated results are not scientific facts")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                            .padding(.bottom, 16)
                            .multilineTextAlignment(.center)
                            .opacity(disclaimerOpacity)

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
                        .accessibilityLabel("Get Started")
                        .accessibilityHint("Begin using SkySniffer to analyze contrail patterns")
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

            // Phone pickup animation - starts tilted and small, then lifts up
            withAnimation(.spring(response: 0.9, dampingFraction: 0.75)) {
                videoOpacity = 1
                videoOffset = 0
                videoScale = 1.0
                videoRotation = 0
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                titleOpacity = 1
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4)) {
                disclaimerOpacity = 1
            }

            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
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
