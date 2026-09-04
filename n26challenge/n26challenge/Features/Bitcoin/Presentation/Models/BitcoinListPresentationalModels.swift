import Foundation

struct BitcoinHistoryRowPresentationalModel: Equatable, Identifiable, Sendable {
    let date: Date
    let title: String
    let subtitle: String?
    let priceText: String
    
    var id: String { title }
}

struct BitcoinListPresentationalModel: Equatable, Sendable {
    let currentPriceText: String
    let rows: [BitcoinHistoryRowPresentationalModel]
}
