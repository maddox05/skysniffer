//
//  PersistenceLevelHelper.swift
//  test_app
//
//  Created by Claude on 12/4/25.
//

import SwiftUI

struct PersistenceLevelHelper {
    let level: String

    var color: Color {
        switch level.lowercased() {
        case "low":
            return .green
        case "medium":
            return .orange
        case "high":
            return .red
        default:
            return .gray
        }
    }

    var fullMessage: String {
        switch level.lowercased() {
        case "low":
            return "Minimal Climate Impact"
        case "medium":
            return "Moderate Warming Effect"
        case "high":
            return "Significant Heat Trapping"
        default:
            return "Minimal Climate Impact"
        }
    }

    var shortMessage: String {
        switch level.lowercased() {
        case "low":
            return "Minimal Impact"
        case "medium":
            return "Warming Effect"
        case "high":
            return "Heat Trapping"
        default:
            return "Minimal Impact"
        }
    }

    var icon: String {
        switch level.lowercased() {
        case "low":
            return "checkmark.circle.fill"
        case "medium":
            return "exclamationmark.circle.fill"
        case "high":
            return "exclamationmark.triangle.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
}
