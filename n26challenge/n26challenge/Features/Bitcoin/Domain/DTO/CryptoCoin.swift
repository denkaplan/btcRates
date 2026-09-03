import Foundation

nonisolated enum CryptoCoin: Equatable, Sendable {
    case bitcoin

    nonisolated var apiIdentifier: String {
        switch self {
        case .bitcoin:
            return "bitcoin"
        }
    }

    nonisolated var displaySymbol: String {
        switch self {
        case .bitcoin:
            return "BTC"
        }
    }
}
