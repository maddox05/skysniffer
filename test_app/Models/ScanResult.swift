//
//  ScanResult.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI
import SwiftData

@Model
final class ScanResult {
    var id: UUID
    var timestamp: Date
    var isValidImage: Bool
    var hasPersistentContrails: Bool
    var aiResponse: String
    var confidenceScore: Double
    var detectedPatterns: [String]
    var atmosphericConditions: String
    var persistenceLevel: String
    @Attribute(.externalStorage) var imageData: Data?

    init(timestamp: Date = Date(), isValidImage: Bool, hasPersistentContrails: Bool, aiResponse: String, confidenceScore: Double, detectedPatterns: [String], atmosphericConditions: String, persistenceLevel: String, imageData: Data?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.isValidImage = isValidImage
        self.hasPersistentContrails = hasPersistentContrails
        self.aiResponse = aiResponse
        self.confidenceScore = confidenceScore
        self.detectedPatterns = detectedPatterns
        self.atmosphericConditions = atmosphericConditions
        self.persistenceLevel = persistenceLevel
        self.imageData = imageData
    }

    // Convenience initializer from DetectionResult
    convenience init(from detection: DetectionResult, imageData: Data?, timestamp: Date = Date()) {
        self.init(
            timestamp: timestamp,
            isValidImage: detection.isValidImage,
            hasPersistentContrails: detection.hasPersistentContrails,
            aiResponse: detection.explanation,
            confidenceScore: detection.confidenceScore,
            detectedPatterns: detection.detectedPatterns,
            atmosphericConditions: detection.atmosphericConditions,
            persistenceLevel: detection.persistenceLevel,
            imageData: imageData
        )
    }

    // Convert to DetectionResult for display
    var asDetectionResult: DetectionResult {
        DetectionResult(
            isValidImage: isValidImage,
            hasPersistentContrails: hasPersistentContrails,
            explanation: aiResponse,
            confidenceScore: confidenceScore,
            detectedPatterns: detectedPatterns,
            atmosphericConditions: atmosphericConditions,
            persistenceLevel: persistenceLevel
        )
    }
}
