import SwiftUI

struct BitcoinListView: View {
    @ObservedObject var viewModel: BitcoinListViewModel

    private let headerHeight: CGFloat = 180

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                content
                    .padding(.top, headerHeight + 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                viewModel.retry()
            }

            LivePriceHeader(
                priceText: viewModel.currentPriceText,
                lastUpdatedText: viewModel.lastUpdatedText,
                height: headerHeight
            )
            .ignoresSafeArea(.all)
            .zIndex(1)
        }
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.contentState {
        case .loading:
            ProgressView("Loading prices…")
                .frame(maxWidth: .infinity, minHeight: 240)
        case .failed(let message):
            ErrorStateView(
                title: "Unable to load Bitcoin prices",
                systemImage: "wifi.exclamationmark",
                message: message,
                retry: viewModel.retry
            )
            .frame(minHeight: 360)
        case .loaded(let rows, let message):
            if let message {
                Text(message)
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

#Preview {
    BitcoinListView(
        viewModel: BitcoinListViewModel(
            getBitcoinHistoryUseCase: PreviewBitcoinHistoryUseCase(),
            observeBitcoinCurrentPriceUseCase: PreviewObserveBitcoinCurrentPriceUseCase(),
            presentationalModelConverter: BitcoinListPresentationalModelConverterImpl(),
            onSelect: { _ in }
        )
    )
}

private struct PreviewBitcoinHistoryUseCase: GetBitcoinHistoryUseCase {
    func execute(daysIncludingToday: Int) async throws -> [HistoryPrice] {
        makeHistory(daysIncludingToday: daysIncludingToday)
    }
}

private struct PreviewObserveBitcoinCurrentPriceUseCase: ObserveBitcoinCurrentPriceUseCase {
    func stream(interval: TimeInterval) -> AsyncStream<Result<Price, Error>> {
        AsyncStream { continuation in
            continuation.yield(.success(Price(date: Date(), eur: 58_500, usd: 63_000, gbp: 49_000)))
            continuation.finish()
        }
    }
}

private func makeHistory(daysIncludingToday: Int) -> [HistoryPrice] {
    (0..<daysIncludingToday).map { offset in
        HistoryPrice(
            date: Calendar.utc.requiredDate(byAdding: .day, value: -offset, to: Calendar.utc.startOfDay(for: Date())),
            eur: Decimal(58_000 - offset * 400)
        )
    }
}
