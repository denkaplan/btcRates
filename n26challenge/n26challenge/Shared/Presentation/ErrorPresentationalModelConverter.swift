import Foundation

protocol ErrorPresentationalModelConverter: Sendable {
    func convert(_ error: Error) -> ErrorPresentationalModel
    func livePriceRefreshError() -> ErrorPresentationalModel
}

struct ErrorPresentationalModelConverterImpl: ErrorPresentationalModelConverter {
    func convert(_ error: Error) -> ErrorPresentationalModel {
        guard let networkError = error as? NetworkError else {
            return ErrorPresentationalModel(
                title: "Something went wrong",
                message: "We couldn’t complete your request. Please try again.",
                systemImage: "exclamationmark.triangle"
            )
        }

        switch networkError {
        case .badRequest, .http(400):
            return ErrorPresentationalModel(
                title: "Invalid request",
                message: "We couldn’t request the Bitcoin price correctly. Please try again later.",
                systemImage: "exclamationmark.triangle"
            )
        case .http(429):
            return ErrorPresentationalModel(
                title: "Price service rate limit",
                message: "Too many requests. Pull to refresh later",
                systemImage: "arrow.clockwise.circle"
            )
        case .http(500):
            return ErrorPresentationalModel(
                title: "Service unavailable",
                message: "The Bitcoin price service is having problems. Please try again in a moment.",
                systemImage: "server.rack"
            )
        case .http:
            return ErrorPresentationalModel(
                title: "Price service error",
                message: "The Bitcoin price service returned an unexpected response. Please try again.",
                systemImage: "exclamationmark.icloud"
            )
        case .noInternet:
            return ErrorPresentationalModel(
                title: "No internet connection",
                message: "Check your connection and try again.",
                systemImage: "wifi.exclamationmark"
            )
        case .timeout:
            return ErrorPresentationalModel(
                title: "Request timed out",
                message: "The price service took too long to respond. Please try again.",
                systemImage: "clock.badge.exclamationmark"
            )
        case .decoding:
            return ErrorPresentationalModel(
                title: "Unexpected data",
                message: "We couldn’t read the latest Bitcoin price. Please try again later.",
                systemImage: "doc.text.magnifyingglass"
            )
        case .unknown:
            return ErrorPresentationalModel(
                title: "Something went wrong",
                message: "We couldn’t load the Bitcoin price. Please try again.",
                systemImage: "exclamationmark.triangle"
            )
        }
    }

    func livePriceRefreshError() -> ErrorPresentationalModel {
        ErrorPresentationalModel(
            title: "Live price not updated",
            message: "Could not refresh live price. Pull to retry.",
            systemImage: "arrow.clockwise"
        )
    }
}
