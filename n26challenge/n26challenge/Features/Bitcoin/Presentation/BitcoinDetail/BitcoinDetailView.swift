import SwiftUI

struct BitcoinDetailView: View {
    @ObservedObject var viewModel: BitcoinDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading price…")
            case .failed(let error):
                ErrorStateView(
                    model: error,
                    retry: viewModel.retry
                )
            case .loaded(let model):
                loaded(model)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.onAppear()
        }
    }

    private func loaded(_ model: BitcoinDetailPresentationalModel) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.dateText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(model.title)
                        .font(.largeTitle.bold())
                }
                .padding(.vertical, 8)
            }

            Section("Currencies") {
                ForEach(model.currencyRows) { row in
                    BitcoinCurrencyRowView(row: row)
                }
            }
        }
    }
}
#Preview {
    BitcoinDetailView(
        viewModel: BitcoinDetailViewModel(
            date: Date(),
            getDetailPriceUseCase: PreviewBitcoinDetailUseCase(),
            presentationalModelConverter: BitcoinDetailPresentationalModelConverterImpl(),
            errorPresentationalModelConverter: ErrorPresentationalModelConverterImpl()
        )
    )
}

private struct PreviewBitcoinDetailUseCase: GetBitcoinDetailPriceUseCase {
    func execute(date: Date) async throws -> Price {
        Price(date: date, eur: 58_000, usd: 63_000, gbp: 49_000)
    }
}
