import Foundation

enum NetworkError: LocalizedError, Sendable {
    case unknown
    case badRequest
    case http(Int)
    case decoding(DecodingError)
    case noInternet
    case timeout
}
