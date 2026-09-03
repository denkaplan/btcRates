import SwiftUI

struct BitcoinDetailView: View {
    @ObservedObject var viewModel: BitcoinDetailViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading(let model):
                loaded(model, message: nil, showsLoading: true)
            case .loaded(let model, let message):
                loaded(model, message: message, showsLoading: false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.onAppear()
        }
    }

    private func loaded(
        _ model: BitcoinDetailPresentationalModel,
        message: ErrorPresentationalModel?,
        showsLoading: Bool
    ) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.dateText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(model.title)
                        .font(.largeTitle.bold())
                    if showsLoading {
                        ProgressView("Refreshing latest prices…")
                            .padding(.top, 8)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Currencies") {
                ForEach(model.currencyRows) { row in
                    BitcoinCurrencyRowView(row: row)
                }
            }

            if let message {
                Section {
                    InlineErrorView(model: message, retry: viewModel.retry)
                }
            }
        }
    }
}

#Preview {
    BitcoinDetailView(
        viewModel: BitcoinDetailViewModel(
            initialHistoryRow: BitcoinHistoryRowPresentationalModel(
                id: "preview",
                date: Date(),
                title: DateFormatter.displayDay.string(from: Date()),
                subtitle: nil,
                priceText: "€58,000.00"
            ),
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
