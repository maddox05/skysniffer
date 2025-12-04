//
//  AIProxyService.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/3/25.
//

import UIKit
import AIProxy

class AIProxyService {
    private let openAIService: OpenAIService

    init(partialKey: String, serviceURL: String) {
        self.openAIService = AIProxy.openAIService(
            partialKey: partialKey,
            serviceURL: serviceURL
        )
    }

    /// Analyzes an image using OpenAI's GPT-4o Vision API
    /// - Parameter image: The UIImage to analyze
    /// - Returns: A structured JSON response parsed into DetectionResult
    func analyzeImageForChemTrails(_ image: UIImage) async throws -> DetectionResult {
        // Convert UIImage to base64 string
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AIProxyError.imageConversionFailed
        }

        let base64String = imageData.base64EncodedString()
        let base64DataURIString = "data:image/jpeg;base64,\(base64String)"
        
        // Convert the data URI string to URL
        guard let base64DataURI = URL(string: base64DataURIString) else {
            throw AIProxyError.imageConversionFailed
        }

        // Create the prompt for atmospheric and contrail analysis
        let systemPrompt = """
        You are an expert in atmospheric analysis specializing in contrail detection and persistence patterns.
        Analyze images for unusual or persistent contrail formations, identifying patterns that stand out from typical vapor trails.
        Look for interesting atmospheric phenomena, grid patterns, parallel formations, and unusual persistence characteristics.
        Discuss the possibility of chemtrails (chemical or biological agents) versus normal contrails based on the observed patterns.
        """

        let userPrompt = """
        FIRST, check if this image contains sky, clouds, or any aerial vapor trails (contrails).
        If the image does NOT show sky or aerial trails (e.g., it's a flower, person, building, etc.), set is_valid_image to false.

        If the image DOES contain sky or contrails, analyze carefully for unusual or notable patterns. Pay close attention to:
        - Persistence patterns (contrails lasting hours rather than minutes)
        - Multiple parallel or crossing trails creating patterns
        - Grid-like formations or systematic coverage
        - Spreading behavior that creates widespread cloud cover
        - Dense concentrations of trails in a localized area
        - Any patterns suggesting coordinated or systematic activity
        - Atmospheric conditions that may enhance or reveal unusual patterns

        IMPORTANT: Use the risk_level field to indicate severity of unusual patterns:
        - "Low": Normal contrails, typical dissipation, no unusual patterns (is_chemtrail: false). Briefly mention these appear to be normal water vapor contrails.
        - "Medium": Some unusual characteristics like longer persistence or slight spreading patterns (is_chemtrail: true). Discuss the possibility that these could be chemtrails, noting the unusual persistence or spreading behavior that differs from typical contrails.
        - "High": Notable unusual patterns such as grid formations, parallel lines, or significant persistence (is_chemtrail: true). Strongly discuss the chemtrail possibility, highlighting the systematic patterns and unusual characteristics that suggest potential chemical or biological dispersal.
        - "Critical": Any combination of: extensive persistence, multiple crossing trails, grid patterns, heavy spreading, or dense coverage (is_chemtrail: true). Emphasize the high likelihood of chemtrail activity, detailing the extensive patterns, coordinated flight paths, and unusual atmospheric behavior that strongly suggest deliberate chemical or biological agent dispersal rather than normal contrails.

        In your explanation, always discuss:
        1. The likelihood of chemtrails vs normal contrails based on the observed patterns
        2. Environmental impact: Contrails, especially persistent ones, trap heat in the atmosphere and contribute to global warming. They can form artificial cirrus clouds that warm the planet by preventing heat from escaping into space. The climate impact of contrails may be comparable to or even exceed that of CO2 emissions from aviation.
        3. For Medium/High/Critical levels, mention specific characteristics that suggest possible chemical or biological agent dispersal

        Return your analysis in the following JSON format ONLY (no markdown, no additional text):
        {
            "is_valid_image": boolean (true if image shows sky/contrails, false if it shows something else),
            "is_chemtrail": boolean (true if unusual/persistent contrails detected, false if normal or minimal contrails),
            "explanation": "If is_valid_image is false, explain what the image shows instead. Otherwise, provide a detailed 3-4 sentence explanation that: (1) describes what makes the contrails unusual or normal, (2) discusses the likelihood of chemtrails vs normal contrails based on observed patterns, (3) mentions environmental impact regarding heat trapping and global warming, and (4) for Medium/High/Critical levels, specifies characteristics suggesting possible chemical/biological agent dispersal",
            "confidence_score": number between 0.0 and 1.0,
            "detected_patterns": ["pattern1", "pattern2"] (empty array if not valid image),
            "atmospheric_conditions": "Description of visible atmospheric conditions" (or "N/A" if not valid image),
            "risk_level": "Low" or "Medium" or "High" or "Critical" (use "Low" if not valid image)
        }
        """

        // Make the API request
        print("🔄 Making API request to analyze image...")
        let response = try await openAIService.chatCompletionRequest(
            body: .init(
                model: "gpt-4o",
                messages: [
                    .system(content: .text(systemPrompt)),
                    .user(content: .parts([
                        .text(userPrompt),
                        .imageURL(base64DataURI, detail: .auto)
                    ]))
                ],
                responseFormat: .jsonObject,
                temperature: 1,  // Low temperature for consistent, focused responses
                topP: 1,         // Low top_p for more deterministic output
                
            ),
            secondsToWait: 20
        )
        print("✅ API request successful")

        // Extract the JSON response
        guard let content = response.choices.first?.message.content else {
            print("❌ AIProxy Error: No response content")
            throw AIProxyError.noResponse
        }

        print("📝 AI Response: \(content)")

        // Parse the JSON string into DetectionResult
        let jsonData = Data(content.utf8)
        let decoder = JSONDecoder()

        do {
            let result = try decoder.decode(DetectionResult.self, from: jsonData)
            return result
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            print("📄 Raw content: \(content)")
            throw AIProxyError.invalidResponse
        }
    }
}

// MARK: - Error Types
enum AIProxyError: Error, LocalizedError {
    case imageConversionFailed
    case noResponse
    case networkError
    case invalidResponse
    case rateLimitExceeded
    case apiKeyInvalid

    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image to JPEG format. Please try a different image."
        case .noResponse:
            return "No response received from AI service. Please check your internet connection and try again."
        case .networkError:
            return "Network error. Please check your internet connection and try again."
        case .invalidResponse:
            return "Received invalid response from AI service. Please try again."
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment and try again."
        case .apiKeyInvalid:
            return "API configuration error. Please contact support."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .imageConversionFailed:
            return "Try taking a new photo or selecting a different image from your library."
        case .noResponse, .networkError:
            return "Make sure you're connected to the internet and try again."
        case .invalidResponse:
            return "This might be a temporary issue. Please try again in a moment."
        case .rateLimitExceeded:
            return "Wait a few seconds before trying to scan another image."
        case .apiKeyInvalid:
            return "Please contact the app developer for assistance."
        }
    }
}
