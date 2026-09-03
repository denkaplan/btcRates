import Foundation
import Testing
@testable import n26challenge

struct ErrorPresentationalModelConverterTests {
    private let converter = ErrorPresentationalModelConverterImpl()

    @Test func mapsBadRequestHTTP400AndBadRequestError() {
        // Arrange
        let httpError = NetworkError.http(400)
        let badRequestError = NetworkError.badRequest

        // Act
        let httpModel = converter.convert(httpError)
        let badRequestModel = converter.convert(badRequestError)

        // Assert
        #expect(httpModel.title == "Invalid request")
        #expect(badRequestModel.title == "Invalid request")
    }

    @Test func mapsHTTP429ToRateLimitMessage() {
        // Arrange
        let error = NetworkError.http(429)

        // Act
        let model = converter.convert(error)

        // Assert
        #expect(model.title == "Price service rate limit")
        #expect(model.message.contains("Too many requests"))
        #expect(model.systemImage == "arrow.clockwise.circle")
    }

    @Test func mapsHTTP500ToServiceUnavailableMessage() {
        // Arrange
        let error = NetworkError.http(500)

        // Act
        let model = converter.convert(error)

        // Assert
        #expect(model.title == "Service unavailable")
        #expect(model.message.contains("having problems"))
        #expect(model.systemImage == "server.rack")
    }

    @Test func mapsOtherHTTPStatusToGenericServiceError() {
        // Arrange
        let error = NetworkError.http(503)

        // Act
        let model = converter.convert(error)

        // Assert
        #expect(model.title == "Price service error")
        #expect(model.message.contains("unexpected response"))
    }

    @Test func mapsNoInternetTimeoutDecodingAndUnknownErrors() {
        // Arrange
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Broken"))

        // Act
        let noInternetModel = converter.convert(NetworkError.noInternet)
        let timeoutModel = converter.convert(NetworkError.timeout)
        let unknownModel = converter.convert(NetworkError.unknown)
        let decodingModel = converter.convert(NetworkError.decoding(decodingError))

        // Assert
        #expect(noInternetModel.title == "No internet connection")
        #expect(timeoutModel.title == "Request timed out")
        #expect(unknownModel.title == "Something went wrong")
        #expect(decodingModel.title == "Unexpected data")
    }

    @Test func mapsNonNetworkErrorsToGenericError() {
        // Arrange
        let error = TestError()

        // Act
        let model = converter.convert(error)

        // Assert
        #expect(model.title == "Something went wrong")
        #expect(model.message.contains("complete your request"))
    }

    @Test func createsLivePriceRefreshError() {
        // No input required.

        // Arrange
        let model = converter.livePriceRefreshError()

        // Act
        // Assert
        #expect(model.title == "Live price not updated")
        #expect(model.message == "Could not refresh live price. Pull to retry.")
    }
}

private struct TestError: Error {}
