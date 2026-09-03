import Foundation

protocol Endpoint: Sendable {
    associatedtype Response: Decodable
    associatedtype Body: Encodable

    var responseType: Response.Type { get }
    var path: String { get }
    var method: NetworkRequest { get }
    var body: Body? { get }
    var queryParams: [(key: String, value: String)] { get }
    var headers: [(key: String, value: String)] { get }
}

struct EndpointBuilder<R: Decodable & Sendable, B: Encodable & Sendable>: Endpoint {
    typealias Response = R
    typealias Body = B

    let path: String
    let responseType: Response.Type = R.self
    let method: NetworkRequest
    let body: B?
    let queryParams: [(key: String, value: String)]
    let headers: [(key: String, value: String)]

    init(
        _ path: String,
        method: NetworkRequest = .GET,
        body: B? = nil,
        queryParams: [(key: String, value: String)] = [],
        headers: [(key: String, value: String)] = []
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.queryParams = queryParams
        self.headers = headers
    }

    @discardableResult
    func withMethod(_ method: NetworkRequest) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams, headers: headers)
    }

    @discardableResult
    func withBody(_ body: B?) -> Self {
        .init(path, method: .POST, body: body, queryParams: queryParams, headers: headers)
    }

    @discardableResult
    func withQuery(_ key: String, _ value: String) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams + [(key, value)], headers: headers)
    }

    @discardableResult
    func withHeader(_ key: String, _ value: String) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams, headers: headers + [(key, value)])
    }
}

struct Blank: Codable, Sendable {}
