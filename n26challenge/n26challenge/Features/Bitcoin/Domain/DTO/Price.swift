import Foundation

struct Price: Equatable, Sendable {
    let date: Date
    let eur: Decimal
    let usd: Decimal?
    let gbp: Decimal?

    init(
        date: Date,
        eur: Decimal,
        usd: Decimal? = nil,
        gbp: Decimal? = nil
    ) {
        self.date = date
        self.eur = eur
        self.usd = usd
        self.gbp = gbp
    }
}
