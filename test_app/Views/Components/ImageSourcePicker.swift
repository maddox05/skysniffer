//
//  ImageSourcePicker.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct ImageSourcePicker: View {
    let onTakePhoto: () -> Void
    let onChooseLibrary: () -> Void
    @State private var cameraPressed = false
    @State private var libraryPressed = false

    var body: some View {
        VStack(spacing: 12) {
            // Take Photo button
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                cameraPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cameraPressed = false
                    onTakePhoto()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)

                    Text("Take Photo")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                )
                .scaleEffect(cameraPressed ? 0.96 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Take Photo")
            .accessibilityHint("Opens camera to photograph the sky")

            // Choose Library button
            Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                libraryPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    libraryPressed = false
                    onChooseLibrary()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)

                    Text("Choose from Library")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                )
                .scaleEffect(libraryPressed ? 0.96 : 1.0)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Choose from Library")
            .accessibilityHint("Select an existing photo from your photo library")
        }
        .padding(.horizontal, 40)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: cameraPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: libraryPressed)
    }
}

#Preview {
    ImageSourcePicker(onTakePhoto: {}, onChooseLibrary: {})
}
