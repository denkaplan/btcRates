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
