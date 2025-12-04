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
    /// - Parameter image: The UIImage to analyze for contrail patterns
    /// - Returns: A structured JSON response parsed into DetectionResult
    func analyzeImageForContrails(_ image: UIImage) async throws -> DetectionResult {
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
        You are an atmospheric science expert specializing in contrail formation, persistence patterns, and aviation weather phenomena.
        Analyze images for contrail formations, identifying patterns and atmospheric conditions that affect their persistence and spread.
        Focus on scientific analysis of contrail behavior, meteorological conditions, and atmospheric physics.
        Provide educational insights about contrail formation, persistence factors, and environmental impact.
        """

        let userPrompt = """
        FIRST, check if this image contains sky, clouds, or any aerial vapor trails (contrails).
        If the image does NOT show sky or aerial trails (e.g., it's a flower, person, building, etc.), set is_valid_image to false.

        If the image DOES contain sky or contrails, provide a scientific analysis of the contrail patterns. Pay close attention to:
        - Persistence characteristics (short-lived vs. long-lasting contrails)
        - Atmospheric conditions affecting contrail formation (humidity, temperature, pressure)
        - Pattern formations (parallel tracks, crossing patterns, spreading behavior)
        - Contrail-to-cirrus cloud transitions
        - Air traffic density and flight corridors
        - Meteorological factors (high altitude ice supersaturation, wind patterns)

        IMPORTANT: Use the persistence_level field to categorize contrail behavior and environmental impact:
        - "Low": Short-lived contrails that dissipate quickly (within minutes). Minimal climate impact. Set has_persistent_contrails to false.
        - "Medium": Moderately persistent contrails lasting 10-30 minutes with some spreading. These contribute to atmospheric warming through heat trapping. Set has_persistent_contrails to true.
        - "High": Highly persistent contrails lasting over an hour with significant spreading and cirrus cloud formation, or extensive coverage with multiple crossing patterns. Notable climate impact from heat-trapping artificial clouds. Set has_persistent_contrails to true.

        In your explanation, provide balanced, educational analysis:
        1. The atmospheric conditions (humidity, temperature, ice supersaturation) that explain the observed contrail behavior
        2. Environmental impact appropriate to the persistence level, noting that persistent contrails trap heat in the atmosphere and contribute to global warming by preventing heat from escaping to space
        3. Keep explanations concise (2-3 sentences) and factual - avoid over-dramatic language while still being informative about climate effects

        Return your analysis in the following JSON format ONLY (no markdown, no additional text):
        {
            "is_valid_image": boolean (true if image shows sky/contrails, false if it shows something else),
            "has_persistent_contrails": boolean (true if moderately-to-highly persistent contrails detected, false if short-lived or minimal contrails),
            "explanation": "If is_valid_image is false, explain what the image shows instead. Otherwise, provide a concise 2-3 sentence explanation that: (1) describes the contrail persistence and atmospheric conditions, (2) mentions the environmental impact relative to the persistence level in a factual, educational manner",
            "confidence_score": number between 0.0 and 1.0,
            "detected_patterns": ["pattern1", "pattern2"] (empty array if not valid image. Examples: "Parallel flight tracks", "Contrail spreading", "Ice supersaturation region", "Contrail-cirrus transition"),
            "atmospheric_conditions": "Description of visible atmospheric conditions and meteorological factors" (or "N/A" if not valid image),
            "persistence_level": "Low" or "Medium" or "High" (use "Low" if not valid image)
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
