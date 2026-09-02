
//
//  NetworkProvider.swift
//  
//
//  Created by Deniz Kaplan on 23.02.24.
//

import Combine
import Foundation

public protocol NetworkProvider {
    @discardableResult
    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response
}

public enum NetworkRequest: String {
    case GET
    case POST
}

public final class NetworkProviderImpl {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let errorLogger: ((Error, [String: Any]?) -> Void)

    public init(
        configuration: NetworkConfiguration,
        errorLogger: @escaping ((Error, [String: Any]?) -> Void)
    ) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        self.session = URLSession(configuration: sessionConfiguration)
        self.configuration = configuration
        self.errorLogger = errorLogger
    }
}

extension NetworkProviderImpl: NetworkProvider {
     private func execute<T>(_ endpoint: T) -> AnyPublisher<T.Response, Error> where T : Endpoint {
        guard let request = makeRequest(from: endpoint) else {
               return Fail(error: NetworkError.badRequest).eraseToAnyPublisher()
           }
           
           return session.dataTaskPublisher(for: request)
               .tryMap { output -> Data? in
                   guard let httpResponse = output.response as? HTTPURLResponse else {
                       throw NetworkError.unknown
                   }
                   guard (200..<300).contains(httpResponse.statusCode) else {
                       throw NetworkError.http(httpResponse.statusCode)
                   }
                   return output.data.isEmpty ? nil : output.data
               }
               .tryMap { [weak self] data -> T.Response? in
                   if T.Response.self == Blank.self {
                       return Blank() as? T.Response
                   }
                   guard let data, let self else { return Blank() as? T.Response }
                   return try decoder.decode(T.Response.self, from: data)
                   
               }
               .compactMap { $0 }
               .mapError { error -> Error in
                   if let decodingError = error as? DecodingError {
                       return NetworkError.decoding(decodingError)
                   }
                   let errorCode = (error as NSError).code
                   if let urlError = (error as? URLError) {
                       switch urlError.code {
                       case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost:
                           return NetworkError.noInternet
                       case .timedOut: return NetworkError.timeout
                       default: break
                       }
                   }
                   if (error as NSError).code == NSURLErrorTimedOut {
                       return NetworkError.timeout
                   }
                   return error
               }
               .eraseToAnyPublisher()
    }
    
    public func execute<T>(_ endpoint: T) async throws -> T.Response where T : Endpoint {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = execute(endpoint)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished: break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                            cancellable?.cancel()
                            cancellable = nil
                        }
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                        cancellable?.cancel()
                        cancellable = nil
                    }
                )
        }
    }

    private func makeRequest(from endpoint: any Endpoint) -> URLRequest? {
        let host = configuration.host
        var components = URLComponents(string: host)
        components?.path = endpoint.path
        components?.scheme = "https"
        components?.queryItems = endpoint.queryParams.map {
            .init(name: $0.key, value: $0.value)
        }
        guard let url = components?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = endpoint.body {
            let data = try? encoder.encode(body)
            request.httpBody = data
        }
        endpoint.headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return request
    }
}
