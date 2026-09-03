import Foundation

struct HistoryPrice: Equatable, Identifiable, Sendable {
    let date: Date
    let eur: Decimal
    let coin: CryptoCoin

    init(date: Date, eur: Decimal, coin: CryptoCoin = .bitcoin) {
        self.date = date
        self.eur = eur
        self.coin = coin
    }

    var id: Date { Calendar.utc.startOfDay(for: date) }
}
