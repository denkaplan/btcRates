import Foundation

struct MarketPricePoint: Equatable, Sendable {
    let date: Date
    let eur: Decimal
    let coin: CryptoCoin

    init(date: Date, eur: Decimal, coin: CryptoCoin = .bitcoin) {
        self.date = date
        self.eur = eur
        self.coin = coin
    }
}
