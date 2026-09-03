import Foundation
import Testing
@testable import n26challenge

struct EndpointBuilderTests {
    @Test func builderDefaultsToGETWithoutBodyQueryOrHeaders() {
        // Arrange
        let endpoint = EndpointBuilder<Blank, [String: String]>("/health")

        // Act
        // Assert
        #expect(endpoint.path == "/health")
        #expect(endpoint.method == .GET)
        #expect(endpoint.body == nil)
        #expect(endpoint.queryParams.isEmpty)
        #expect(endpoint.headers.isEmpty)
        #expect(endpoint.responseType == Blank.self)
    }

    @Test func builderReturnsCopyWithMethodBodyQueryAndHeaders() {
        // Arrange
        let body = ["key": "value"]

        // Act
        let endpoint = EndpointBuilder<Blank, [String: String]>("/submit")
            .withMethod(.POST)
            .withBody(body)
            .withQuery("page", "1")
            .withHeader("Authorization", "Bearer token")

        // Assert
        #expect(endpoint.method == .POST)
        #expect(endpoint.body == body)
        #expect(endpoint.queryParams.count == 1)
        #expect(endpoint.queryParams.first?.key == "page")
        #expect(endpoint.queryParams.first?.value == "1")
        #expect(endpoint.headers.count == 1)
        #expect(endpoint.headers.first?.key == "Authorization")
        #expect(endpoint.headers.first?.value == "Bearer token")
    }
}
