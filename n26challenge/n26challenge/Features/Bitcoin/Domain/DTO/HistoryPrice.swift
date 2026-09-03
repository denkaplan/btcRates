import Foundation

nonisolated struct HistoryPrice: Equatable, Identifiable, Sendable {
    let date: Date
    let eur: Decimal
    let coin: CryptoCoin

    nonisolated init(date: Date, eur: Decimal, coin: CryptoCoin = .bitcoin) {
        self.date = date
        self.eur = eur
        self.coin = coin
    }

    nonisolated var id: Date { Calendar.utc.startOfDay(for: date) }
}
