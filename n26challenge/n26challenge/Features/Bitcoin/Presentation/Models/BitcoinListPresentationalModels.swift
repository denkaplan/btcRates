import Foundation

struct BitcoinHistoryRowPresentationalModel: Equatable, Identifiable, Sendable {
    let id: String
    let date: Date
    let title: String
    let subtitle: String?
    let priceText: String
}

struct BitcoinListPresentationalModel: Equatable, Sendable {
    let currentPriceText: String
    let rows: [BitcoinHistoryRowPresentationalModel]
}
