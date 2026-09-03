import Foundation

struct Price: Equatable, Identifiable, Sendable {
    let date: Date
    let eur: Decimal
    let usd: Decimal?
    let gbp: Decimal?
    let coin: CryptoCoin

    init(
        date: Date,
        eur: Decimal,
        usd: Decimal? = nil,
        gbp: Decimal? = nil,
        coin: CryptoCoin = .bitcoin
    ) {
        self.date = date
        self.eur = eur
        self.usd = usd
        self.gbp = gbp
        self.coin = coin
    }

    var id: Date { Calendar.utc.startOfDay(for: date) }
}
