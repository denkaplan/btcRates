import Foundation

struct HistoryPrice: Equatable, Sendable {
    let date: Date
    let eur: Decimal

    init(date: Date, eur: Decimal) {
        self.date = date
        self.eur = eur
    }
}
