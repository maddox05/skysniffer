//
//  ContrailAnalysisService.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI

struct DetectionResult: Codable {
    let isValidImage: Bool // Whether image contains sky/contrails
    let hasPersistentContrails: Bool
    let explanation: String
    let confidenceScore: Double // 0.0 to 1.0
    let detectedPatterns: [String]
    let atmosphericConditions: String
    let persistenceLevel: String // "Low", "Medium", "High"

    enum CodingKeys: String, CodingKey {
        case isValidImage = "is_valid_image"
        case hasPersistentContrails = "has_persistent_contrails"
        case explanation
        case confidenceScore = "confidence_score"
        case detectedPatterns = "detected_patterns"
        case atmosphericConditions = "atmospheric_conditions"
        case persistenceLevel = "persistence_level"
    }
}

class ContrailAnalysisService {
    private static let aiProxyService = AIProxyService(
        partialKey: Config.aiProxyPartialKey,
        serviceURL: Config.aiProxyServiceURL
    )

    /// Analyzes an image using OpenAI's GPT-4o Vision API via AIProxy
    /// - Parameter image: The UIImage to analyze for contrail patterns and persistence
    /// - Returns: DetectionResult with AI-powered atmospheric analysis
    static func analyzeImage(_ image: UIImage) async throws -> DetectionResult {
        return try await aiProxyService.analyzeImageForContrails(image)
    }
}
