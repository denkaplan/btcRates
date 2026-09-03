import SwiftUI

struct BitcoinListView: View {
    @ObservedObject var viewModel: BitcoinListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            LivePriceHeader(
                priceText: viewModel.currentPriceText,
                lastUpdatedText: viewModel.lastUpdatedText,
                height: 180
            )
            
            ScrollView {
                content
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                viewModel.retry()
            }

        }
        .ignoresSafeArea(.all, edges: .top)
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.contentState {
        case .loading:
            ProgressView("Loading prices…")
                .frame(maxWidth: .infinity, minHeight: 240)
        case .failed(let error):
            ErrorStateView(
                model: error,
                retry: viewModel.retry
            )
            .frame(minHeight: 360)
        case .loaded(let rows, let message):
            if let message {
                Text(message.message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            Text("Last 14 days")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

            ForEach(rows) { item in
                BitcoinHistoryRowView(item: item) {
                    viewModel.select(item)
                }
            }
        }
    }
}
