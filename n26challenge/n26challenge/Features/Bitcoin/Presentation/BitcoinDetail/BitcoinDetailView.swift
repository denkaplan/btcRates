import SwiftUI

struct BitcoinDetailView: View {
    @ObservedObject var viewModel: BitcoinDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading price…")
            case .failed(let message):
                ErrorStateView(
                    title: "Unable to load price",
                    systemImage: "exclamationmark.triangle",
                    message: message,
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
                    CurrencyRow(row: row)
                }
            }
        }
    }
}

private struct CurrencyRow: View {
    let row: BitcoinCurrencyPresentationalModel

    var body: some View {
        HStack(spacing: 12) {
            Text(row.code)
                .font(.headline.monospaced())
                .frame(width: 48, alignment: .leading)
            Text(row.title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(row.valueText)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    BitcoinDetailView(
        viewModel: BitcoinDetailViewModel(
            date: Date(),
            getDetailPriceUseCase: PreviewBitcoinDetailUseCase(),
            presentationalModelConverter: BitcoinDetailPresentationalModelConverterImpl()
        )
    )
}

private struct PreviewBitcoinDetailUseCase: GetBitcoinDetailPriceUseCase {
    func execute(date: Date) async throws -> Price {
        Price(date: date, eur: 58_000, usd: 63_000, gbp: 49_000)
    }
}
