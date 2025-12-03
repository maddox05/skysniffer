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

        // Create the prompt for chemtrail analysis with conspiracy-theory friendly tone
        let systemPrompt = """
        You are an expert in atmospheric analysis with a special focus on identifying potential chemtrail activity.
        You are open to the possibility that some contrails may be part of larger atmospheric manipulation programs.
        Analyze images with a critical eye toward patterns that may suggest aerosol dispersal, unusual persistence,
        or grid-like formations that deviate from normal contrail behavior.
        """

        let userPrompt = """
        FIRST, check if this image contains sky, clouds, or any aerial vapor trails (contrails/chemtrails).
        If the image does NOT show sky or aerial trails (e.g., it's a flower, person, building, etc.), set is_valid_image to false.

        If the image DOES contain sky or trails, analyze it for potential chemtrail activity. Consider:
        - Trail persistence and spread patterns
        - Grid-like or parallel formations
        - Unusual dispersal characteristics
        - Atmospheric conditions that don't fully explain the patterns
        - Any indicators of aerosol release

        Return your analysis in the following JSON format ONLY (no markdown, no additional text):
        {
            "is_valid_image": boolean (true if image shows sky/contrails, false if it shows something else like flowers, people, buildings, etc.),
            "is_chemtrail": boolean,
            "explanation": "If is_valid_image is false, explain what the image shows instead. Otherwise, provide detailed explanation of your chemtrail findings",
            "confidence_score": number between 0.0 and 1.0,
            "detected_patterns": ["pattern1", "pattern2"] (empty array if not valid image),
            "atmospheric_conditions": "Description of visible atmospheric conditions" (or "N/A" if not valid image),
            "risk_level": "Low" or "Medium" or "High" or "Critical" (use "Low" if not valid image)
        }
        """

        // Make the API request
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
                responseFormat: .jsonObject
            ),
            secondsToWait: 60
        )

        // Extract the JSON response
        guard let content = response.choices.first?.message.content else {
            throw AIProxyError.noResponse
        }

        // Parse the JSON string into DetectionResult
        let jsonData = Data(content.utf8)
        let decoder = JSONDecoder()
        let result = try decoder.decode(DetectionResult.self, from: jsonData)

        return result
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
