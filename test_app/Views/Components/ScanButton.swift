//
//  ScanButton.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct ScanButton: View {
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }) {
            Circle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 4)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundColor(.white)
                )
                .scaleEffect(isPressed ? 0.88 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Scan Sky")
        .accessibilityHint("Take or choose a photo to analyze contrail patterns")
    }
}

#Preview {
    ScanButton(action: {})
}
