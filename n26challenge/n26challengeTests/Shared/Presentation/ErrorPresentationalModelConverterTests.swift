import Foundation
import Testing
@testable import n26challenge

struct ErrorPresentationalModelConverterTests {
    private let converter = ErrorPresentationalModelConverterImpl()

    @Test func mapsBadRequestHTTP400AndBadRequestError() {
        #expect(converter.convert(NetworkError.http(400)).title == "Invalid request")
        #expect(converter.convert(NetworkError.badRequest).title == "Invalid request")
    }

    @Test func mapsHTTP428ToUpdateRequiredMessage() {
        let model = converter.convert(NetworkError.http(428))

        #expect(model.title == "Update required")
        #expect(model.message.contains("updated request"))
        #expect(model.systemImage == "arrow.clockwise.circle")
    }

    @Test func mapsHTTP500ToServiceUnavailableMessage() {
        let model = converter.convert(NetworkError.http(500))

        #expect(model.title == "Service unavailable")
        #expect(model.message.contains("having problems"))
        #expect(model.systemImage == "server.rack")
    }

    @Test func mapsOtherHTTPStatusToGenericServiceError() {
        let model = converter.convert(NetworkError.http(503))

        #expect(model.title == "Price service error")
        #expect(model.message.contains("unexpected response"))
    }

    @Test func mapsNoInternetTimeoutDecodingAndUnknownErrors() {
        #expect(converter.convert(NetworkError.noInternet).title == "No internet connection")
        #expect(converter.convert(NetworkError.timeout).title == "Request timed out")
        #expect(converter.convert(NetworkError.unknown).title == "Something went wrong")

        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Broken"))
        #expect(converter.convert(NetworkError.decoding(decodingError)).title == "Unexpected data")
    }

    @Test func mapsNonNetworkErrorsToGenericError() {
        let model = converter.convert(TestError())

        #expect(model.title == "Something went wrong")
        #expect(model.message.contains("complete your request"))
    }

    @Test func createsLivePriceRefreshError() {
        let model = converter.livePriceRefreshError()

        #expect(model.title == "Live price not updated")
        #expect(model.message == "Could not refresh live price. Pull to retry.")
    }
}

private struct TestError: Error {}
