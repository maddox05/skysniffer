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
                let result = try await ChemTrailDetectionService.analyzeImage(image)

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

                // Provide user-friendly error messages
                if let aiError = error as? AIProxyError {
                    errorMessage = aiError.localizedDescription
                } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    errorMessage = "No internet connection. Please check your network and try again."
                } else if (error as NSError).code == NSURLErrorTimedOut {
                    errorMessage = "Request timed out. Please try again."
                } else {
                    errorMessage = "Unable to analyze image. Please try again."
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
