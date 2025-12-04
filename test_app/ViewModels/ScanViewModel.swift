//
//  ScanViewModel.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI
import SwiftData
import PhotosUI

@Observable
@MainActor
class ScanViewModel {
    var showingImagePicker = false
    var showingCamera = false
    var showingPhotosPicker = false
    var selectedImage: UIImage?
    var selectedPhotoItem: PhotosPickerItem?
    var isScanning = false
    var currentResult: DetectionResult?
    var showingResult = false
    var showingOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    var errorMessage: String?
    var showingError = false

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        showingOnboarding = false
    }

    func performScan(image: UIImage) {
        isScanning = true
        errorMessage = nil
        showingError = false

        Task {
            do {
                let result = try await ContrailAnalysisService.analyzeImage(image)

                // Success haptic
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)

                currentResult = result
                isScanning = false
                showingResult = true
            } catch {
                // Error haptic
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.error)

                isScanning = false

                // Provide user-friendly, actionable error messages
                if let aiError = error as? AIProxyError {
                    switch aiError {
                    case .imageConversionFailed:
                        errorMessage = "Unable to process this image format. Try taking a new photo or selecting a different image."
                    case .noResponse:
                        errorMessage = "No response from AI service. Check your internet connection and try again."
                    case .networkError:
                        errorMessage = "Network connection lost. Make sure you're connected to the internet and try again."
                    case .invalidResponse:
                        errorMessage = "Received unexpected response from AI. This is usually temporary - please try again in a moment."
                    case .rateLimitExceeded:
                        errorMessage = "Too many requests at once. Please wait 10 seconds and try again."
                    case .apiKeyInvalid:
                        errorMessage = "Service configuration error. Please update the app or contact support."
                    }
                } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    errorMessage = "No internet connection detected.\n\nPlease connect to Wi-Fi or cellular data and try again."
                } else if (error as NSError).code == NSURLErrorTimedOut {
                    errorMessage = "Analysis took too long and timed out.\n\nThis can happen with slow connections. Try again with a better connection."
                } else if (error as NSError).code == NSURLErrorCannotConnectToHost {
                    errorMessage = "Cannot reach AI service.\n\nCheck your internet connection and try again."
                } else {
                    errorMessage = "Unable to analyze image.\n\nPlease try again. If the problem persists, try restarting the app."
                }

                showingError = true
                selectedImage = nil
                print("Error during scan: \(error)")
            }
        }
    }

    func saveResult() {
        guard let result = currentResult,
              let image = selectedImage,
              let context = modelContext else { return }

        let imageData = image.jpegData(compressionQuality: 0.8)
        let scan = ScanResult(from: result, imageData: imageData)

        context.insert(scan)

        selectedImage = nil
        currentResult = nil
    }

    func deleteScans(at offsets: IndexSet, from scans: [ScanResult]) {
        guard let context = modelContext else { return }

        for index in offsets {
            context.delete(scans[index])
        }
    }

    func handlePhotoSelection() {
        Task {
            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                selectedPhotoItem = nil
            }
        }
    }
}
