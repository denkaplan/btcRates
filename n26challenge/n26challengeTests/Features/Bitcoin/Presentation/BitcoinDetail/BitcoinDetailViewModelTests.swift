import Foundation
import Testing
@testable import n26challenge

@MainActor
struct BitcoinDetailViewModelTests {
    @Test func onAppearLoadsPresentationModel() async throws {
        let date = Date()
        let price = Price(date: date, eur: 60_000, usd: 65_000, gbp: 51_000)
        let expected = BitcoinDetailPresentationalModel(
            title: "Converted title",
            dateText: "Converted date",
            currencyRows: [BitcoinCurrencyPresentationalModel(currency: .eur, valueText: "EUR 60000")]
        )
        let viewModel = BitcoinDetailViewModel(
            date: date,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .success(price)),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: expected)
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.state == .loaded(expected))
    }

    @Test func onAppearFailureShowsFailureState() async throws {
        let viewModel = BitcoinDetailViewModel(
            date: Date(),
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .failure(NetworkError.timeout)),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(
                result: BitcoinDetailPresentationalModel(title: "", dateText: "", currencyRows: [])
            )
        )

        viewModel.onAppear()
        try await Task.sleep(nanoseconds: 100_000_000)

        guard case .failed(let message) = viewModel.state else {
            Issue.record("Expected failed state")
            return
        }
        #expect(message.isEmpty == false)
    }

    @Test func retryLoadsAgain() async throws {
        let date = Date()
        let expected = BitcoinDetailPresentationalModel(title: "Title", dateText: "Today", currencyRows: [])
        let viewModel = BitcoinDetailViewModel(
            date: date,
            getDetailPriceUseCase: MockGetBitcoinDetailPriceUseCase(result: .success(Price(date: date, eur: 60_000))),
            presentationalModelConverter: MockBitcoinDetailPresentationalModelConverter(result: expected)
        )

        viewModel.retry()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.state == .loaded(expected))
    }
}
