import Foundation
import Testing
@testable import n26challenge

@MainActor
struct FormatterExtensionsTests {
    @Test func apiDayStringFormatsExpectedDate() {
        // Arrange
        // Act
        // Assert
        #expect(DateFormatter.apiDayString(from: requiredAPIDate("03-09-2026")) == "03-09-2026")
    }

    @Test func decimalAsNumberPreservesValue() {
        // Arrange
        // Act
        // Assert
        #expect(Decimal(42).asNumber.decimalValue == Decimal(42))
    }

    @Test func lastUpdatedTextFormatterUsesPooledFormatter() {
        // Arrange
        let formatter = LastUpdatedTextFormatterImpl()

        // Act
        let text = formatter.string(from: requiredAPIDate("03-09-2026"))

        // Assert
        #expect(text.hasPrefix("Updated "))
        #expect(text.count > "Updated ".count)
    }

    @Test func currencyFormatterUsesTypedCurrencyCode() {
        // Arrange
        // Act
        // Assert
        #expect(NumberFormatter.currency(.eur).currencyCode == Currency.eur.code)
        #expect(NumberFormatter.currency(.usd).currencyCode == Currency.usd.code)
        #expect(NumberFormatter.currency(.gbp).currencyCode == Currency.gbp.code)
    }
}
