import Foundation
import Testing
@testable import n26challenge

@MainActor
struct FormatterExtensionsTests {
    @Test func apiDayStringFormatsExpectedDate() {
        #expect(DateFormatter.apiDayString(from: requiredAPIDate("03-09-2026")) == "03-09-2026")
    }

    @Test func decimalAsNumberPreservesValue() {
        #expect(Decimal(42).asNumber.decimalValue == Decimal(42))
    }

    @Test func currencyFormatterUsesTypedCurrencyCode() {
        #expect(NumberFormatter.currency(.eur).currencyCode == Currency.eur.code)
        #expect(NumberFormatter.currency(.usd).currencyCode == Currency.usd.code)
        #expect(NumberFormatter.currency(.gbp).currencyCode == Currency.gbp.code)
    }
}
