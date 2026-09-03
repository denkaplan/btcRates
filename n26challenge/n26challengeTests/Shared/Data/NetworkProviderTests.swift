import Foundation
import Testing
@testable import n26challenge

@Suite(.serialized)
struct NetworkProviderTests {
    @Test func executeBuildsRequestAndDecodesResponseUsingInjectedDecoder() async throws {
        // Arrange
        let session = makeSession { request in
            #expect(request.url?.absoluteString == "https://example.com/api/test?search=bitcoin")
            #expect(request.httpMethod == "GET")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            #expect(request.value(forHTTPHeaderField: "X-Test") == "1")

        // Act
            let response = HTTPURLResponse(
                url: request.url ?? requiredURL("https://example.com"),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (Data("{\"display_name\":\"Bitcoin\"}".utf8), response)
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let provider = NetworkProviderImpl(
            configuration: NetworkConfiguration(host: "https://example.com", jsonDecoder: decoder),
            session: session
        )
        let endpoint = EndpointBuilder<TestResponse, [String: String]>("/api/test")
            .withQuery("search", "bitcoin")
            .withHeader("X-Test", "1")

        let response = try await provider.execute(endpoint)

        // Assert
        #expect(response == TestResponse(displayName: "Bitcoin"))
    }

    @Test func executeReturnsBlankForBlankResponseType() async throws {
        // Arrange
        let session = makeSession { request in
            let response = HTTPURLResponse(
                url: request.url ?? requiredURL("https://example.com"),
                statusCode: 204,
                httpVersion: nil,
                headerFields: nil
            )
            return (Data(), response)
        }
        let provider = NetworkProviderImpl(
            configuration: NetworkConfiguration(host: "https://example.com"),
            session: session
        )

        // Act
        let response: Blank = try await provider.execute(EndpointBuilder<Blank, [String: String]>("/empty"))

        _ = response
        // Assert
    }

    @Test func executeThrowsHTTPErrorForNonSuccessStatusCode() async throws {
        // Arrange
        let session = makeSession { request in
            let response = HTTPURLResponse(
                url: request.url ?? requiredURL("https://example.com"),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )
            return (Data(), response)
        }
        let provider = NetworkProviderImpl(
            configuration: NetworkConfiguration(host: "https://example.com"),
            session: session
        )

        // Act
        // Assert
        do {
            let _: Blank = try await provider.execute(EndpointBuilder<Blank, [String: String]>("/failure"))
            Issue.record("Expected HTTP error")
        } catch NetworkError.http(let statusCode) {
            #expect(statusCode == 500)
        } catch {
            Issue.record("Expected HTTP error, got \(error)")
        }
    }
}

private struct TestResponse: Decodable, Equatable, Sendable {
    let displayName: String
}

private func makeSession(handler: @escaping @Sendable (URLRequest) throws -> (Data, URLResponse?)) -> URLSession {
    MockURLProtocol.requestHandler = handler
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: configuration)
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    static var requestHandler: (@Sendable (URLRequest) throws -> (Data, URLResponse?))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let requestHandler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NetworkError.unknown)
            return
        }

        do {
            let (data, response) = try requestHandler(request)
            if let response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
