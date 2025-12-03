//
//  ChemTrailDetectionService.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI

struct DetectionResult: Codable {
    let isValidImage: Bool // Whether image contains sky/contrails
    let isChemTrail: Bool
    let explanation: String
    let confidenceScore: Double // 0.0 to 1.0
    let detectedPatterns: [String]
    let atmosphericConditions: String
    let riskLevel: String // "Low", "Medium", "High", "Critical"

    enum CodingKeys: String, CodingKey {
        case isValidImage = "is_valid_image"
        case isChemTrail = "is_chemtrail"
        case explanation
        case confidenceScore = "confidence_score"
        case detectedPatterns = "detected_patterns"
        case atmosphericConditions = "atmospheric_conditions"
        case riskLevel = "risk_level"
    }
}

class ChemTrailDetectionService {
    private static let aiProxyService = AIProxyService(
        partialKey: Config.aiProxyPartialKey,
        serviceURL: Config.aiProxyServiceURL
    )

    /// Analyzes an image using OpenAI's GPT-4o Vision API via AIProxy
    /// - Parameter image: The UIImage to analyze for chemtrail detection
    /// - Returns: DetectionResult with AI-powered analysis
    static func analyzeImage(_ image: UIImage) async throws -> DetectionResult {
        return try await aiProxyService.analyzeImageForChemTrails(image)
    }
}
