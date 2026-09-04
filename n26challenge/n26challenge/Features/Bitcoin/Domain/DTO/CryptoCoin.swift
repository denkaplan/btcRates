import Foundation

enum CryptoCoin: Equatable, Sendable {
    case bitcoin

    var apiIdentifier: String {
        switch self {
        case .bitcoin:
            return "bitcoin"
        }
    }

}
