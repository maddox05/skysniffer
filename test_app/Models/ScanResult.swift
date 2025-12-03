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
    var isChemTrail: Bool
    var aiResponse: String
    var confidenceScore: Double
    var detectedPatterns: [String]
    var atmosphericConditions: String
    var riskLevel: String
    @Attribute(.externalStorage) var imageData: Data?

    init(timestamp: Date = Date(), isValidImage: Bool, isChemTrail: Bool, aiResponse: String, confidenceScore: Double, detectedPatterns: [String], atmosphericConditions: String, riskLevel: String, imageData: Data?) {
        self.id = UUID()
        self.timestamp = timestamp
        self.isValidImage = isValidImage
        self.isChemTrail = isChemTrail
        self.aiResponse = aiResponse
        self.confidenceScore = confidenceScore
        self.detectedPatterns = detectedPatterns
        self.atmosphericConditions = atmosphericConditions
        self.riskLevel = riskLevel
        self.imageData = imageData
    }

    // Convenience initializer from DetectionResult
    convenience init(from detection: DetectionResult, imageData: Data?, timestamp: Date = Date()) {
        self.init(
            timestamp: timestamp,
            isValidImage: detection.isValidImage,
            isChemTrail: detection.isChemTrail,
            aiResponse: detection.explanation,
            confidenceScore: detection.confidenceScore,
            detectedPatterns: detection.detectedPatterns,
            atmosphericConditions: detection.atmosphericConditions,
            riskLevel: detection.riskLevel,
            imageData: imageData
        )
    }

    // Convert to DetectionResult for display
    var asDetectionResult: DetectionResult {
        DetectionResult(
            isValidImage: isValidImage,
            isChemTrail: isChemTrail,
            explanation: aiResponse,
            confidenceScore: confidenceScore,
            detectedPatterns: detectedPatterns,
            atmosphericConditions: atmosphericConditions,
            riskLevel: riskLevel
        )
    }
}
