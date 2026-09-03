import Foundation
struct AppDependencyContainer {
    let getBitcoinHistoryUseCase: GetBitcoinHistoryUseCase
    let observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase
    let getBitcoinDetailPriceUseCase: GetBitcoinDetailPriceUseCase
    let bitcoinListPresentationalModelConverter: BitcoinListPresentationalModelConverter
    let bitcoinDetailPresentationalModelConverter: BitcoinDetailPresentationalModelConverter
    let errorPresentationalModelConverter: ErrorPresentationalModelConverter
    let lastUpdatedTextFormatter: LastUpdatedTextFormatter

    private static func makeJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func live() -> AppDependencyContainer {
        let provider = NetworkProviderImpl(
            configuration: NetworkConfiguration(
                host: "https://api.coingecko.com",
                jsonDecoder: makeJSONDecoder()
            ),
            errorLogger: { error, context in
                #if DEBUG
                print("Network error:", error, context ?? [:])
                #endif
            }
        )
        let repository = CoingeckoBitcoinRepositoryImpl(networkProvider: provider)

        return AppDependencyContainer(
            getBitcoinHistoryUseCase: GetBitcoinHistoryUseCaseImpl(repository: repository),
            observeBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCaseImpl(
                repository: repository
            ),
            getBitcoinDetailPriceUseCase: GetBitcoinDetailPriceUseCaseImpl(repository: repository),
            bitcoinListPresentationalModelConverter: BitcoinListPresentationalModelConverterImpl(),
            bitcoinDetailPresentationalModelConverter: BitcoinDetailPresentationalModelConverterImpl(),
            errorPresentationalModelConverter: ErrorPresentationalModelConverterImpl(),
            lastUpdatedTextFormatter: LastUpdatedTextFormatterImpl()
        )
    }
}
