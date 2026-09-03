import Foundation

struct BitcoinDetailPresentationalModel: Equatable, Sendable {
    let title: String
    let dateText: String
    let currencyRows: [BitcoinCurrencyPresentationalModel]
}

struct BitcoinCurrencyPresentationalModel: Equatable, Identifiable, Sendable {
    let currency: Currency
    let valueText: String

    var id: String { currency.id }
    var code: String { currency.code }
    var title: String { currency.description }
}
