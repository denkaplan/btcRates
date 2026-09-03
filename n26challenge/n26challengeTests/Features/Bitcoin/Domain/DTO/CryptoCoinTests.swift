import Foundation
import Testing
@testable import n26challenge

struct CryptoCoinTests {
    @Test func bitcoinExposesApiIdentifierAndDisplaySymbol() {
        // Arrange
        // Act
        // Assert
        #expect(CryptoCoin.bitcoin.apiIdentifier == "bitcoin")
        #expect(CryptoCoin.bitcoin.displaySymbol == "BTC")
    }
}
