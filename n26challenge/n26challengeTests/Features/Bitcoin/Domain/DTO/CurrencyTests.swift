import Foundation
import Testing
@testable import n26challenge

struct CurrencyTests {
    @Test func supportedCurrenciesExposeTypedMetadata() {
        // Arrange
        // Act
        // Assert
        #expect(Currency.allCases == [.eur, .usd, .gbp])
        #expect(Currency.eur.id == "EUR")
        #expect(Currency.eur.code == "EUR")
        #expect(Currency.eur.apiCode == "eur")
        #expect(Currency.eur.description == "Euro")
        #expect(Currency.usd.description == "US Dollar")
        #expect(Currency.gbp.description == "British Pound")
    }
}
