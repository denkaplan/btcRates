import Foundation
@testable import n26challenge

final class MockNetworkProvider: NetworkProvider {
    private let response: @Sendable (any Endpoint) throws -> Any

    init(response: @escaping @Sendable (any Endpoint) throws -> Any) {
        self.response = response
    }

    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        guard let typedResponse = try response(endpoint) as? T.Response else {
            throw NetworkError.unknown
        }
        return typedResponse
    }
}
