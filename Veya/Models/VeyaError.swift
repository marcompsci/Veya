import Foundation

enum VeyaError: LocalizedError, Equatable {
    case noImage
    case noQuestion
    case analysisFailure(String)
    case networkUnavailable
    case imageProcessingFailed
    case permissionDenied(String)
    case sessionNotFound
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .noImage:
            return "Please share an image for Veya to analyze."
        case .noQuestion:
            return "Please ask Veya a question about the image."
        case .analysisFailure(let detail):
            return "Veya couldn't complete the analysis. \(detail)"
        case .networkUnavailable:
            return "A connection is needed to create your guide. Please check your network."
        case .imageProcessingFailed:
            return "Veya had trouble reading the image. Please try a different one."
        case .permissionDenied(let feature):
            return "Access to \(feature) was denied. You can update this in Settings."
        case .sessionNotFound:
            return "This guide could not be found."
        case .decodingFailed:
            return "Veya received an unexpected response. Please try again."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Open Settings to grant access."
        case .networkUnavailable:
            return "Connect to Wi-Fi or cellular data and try again."
        default:
            return "Please try again."
        }
    }

    var systemImage: String {
        switch self {
        case .noImage:           return "photo.badge.plus"
        case .noQuestion:        return "questionmark.bubble"
        case .networkUnavailable: return "wifi.exclamationmark"
        case .permissionDenied:  return "lock.fill"
        default:                 return "exclamationmark.triangle"
        }
    }
}
