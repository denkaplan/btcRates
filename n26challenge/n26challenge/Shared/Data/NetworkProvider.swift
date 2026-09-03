import Foundation

protocol NetworkProvider: Sendable {
    @discardableResult
    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

final class NetworkProviderImpl: NetworkProvider, @unchecked Sendable {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private let errorLogger: @Sendable (Error, [String: Any]?) -> Void

    init(
        configuration: NetworkConfiguration,
        session: URLSession = .shared,
        errorLogger: @escaping @Sendable (Error, [String: Any]?) -> Void = { _, _ in }
    ) {
        self.configuration = configuration
        self.session = session
        self.errorLogger = errorLogger
    }

    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        guard let request = makeRequest(from: endpoint) else {
            throw NetworkError.badRequest
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw NetworkError.http(httpResponse.statusCode)
            }
            if T.Response.self == Blank.self {
                guard let blankResponse = Blank() as? T.Response else {
                    throw NetworkError.unknown
                }
                return blankResponse
            }
            return try configuration.jsonDecoder.decode(T.Response.self, from: data)
        } catch let decodingError as DecodingError {
            let error = NetworkError.decoding(decodingError)
            errorLogger(error, ["path": endpoint.path])
            throw error
        } catch let urlError as URLError {
            let error: NetworkError
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost:
                error = .noInternet
            case .timedOut:
                error = .timeout
            default:
                error = .unknown
            }
            errorLogger(error, ["path": endpoint.path])
            throw error
        } catch {
            errorLogger(error, ["path": endpoint.path])
            throw error
        }
    }

    private func makeRequest(from endpoint: any Endpoint) -> URLRequest? {
        guard var components = URLComponents(string: configuration.host) else { return nil }
        components.path = endpoint.path
        components.scheme = "https"
        if !endpoint.queryParams.isEmpty {
            components.queryItems = endpoint.queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = endpoint.body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try? encoder.encode(body)
        }
        endpoint.headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return request
    }
}
