//
//  Endpoint.swift
//  Networking
//
//  Created by Deniz Kaplan on 04.10.2025.
//

import Foundation

public struct Blank: Codable {}

public protocol Endpoint {
    associatedtype Response: Decodable
    associatedtype Body: Encodable

    var responseType: Response.Type { get }
    var path: String { get }
    var method: NetworkRequest { get }
    var body: Body? { get }
    var queryParams: [(key: String, value: String)] { get }
    var headers: [(key: String, value: String)] { get }
}

public struct EndpointBuilder<R: Decodable, B: Encodable>: Endpoint {
    public typealias Response = R
    public typealias Body = B
    
    public let path: String
    public let responseType: Response.Type = R.self
    public let method: NetworkRequest
    public let body: B?
    public let queryParams: [(key: String, value: String)]
    public let headers: [(key: String, value: String)]
    
    public init(
        _ path: String,
        method: NetworkRequest = .GET,
        body: B? = nil,
        queryParams: [(key: String, value: String)] = [],
        headers: [(key: String, value: String)] = [],
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.queryParams = queryParams
        self.headers = headers
    }
    
    @discardableResult
    public func withMethod(_ method: NetworkRequest) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams, headers: headers)
    }
    
    @discardableResult
    public func withBody(_ body: B?) -> Self {
        .init(path, method: .POST, body: body, queryParams: queryParams, headers: headers)
    }
    
    @discardableResult
    public func withQuery(_ key: String, _ value: String) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams + [(key, value)], headers: headers)
    }
    
    @discardableResult
    public func withHeader(_ key: String, _ value: String) -> Self {
        .init(path, method: method, body: body, queryParams: queryParams, headers: headers + [(key, value)])
    }
    
    @discardableResult
    public func withAuth(_ token: String) -> Self {
        .init(
            path,
            method: method,
            body: body,
            queryParams: queryParams,
            headers: headers + [("X-Auth", token)],
        )
    }
}
