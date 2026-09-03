import Foundation
import Testing
@testable import n26challenge

struct CryptoCoinTests {
    @Test func bitcoinExposesApiIdentifierAndDisplaySymbol() {
        #expect(CryptoCoin.bitcoin.apiIdentifier == "bitcoin")
        #expect(CryptoCoin.bitcoin.displaySymbol == "BTC")
    }
}
