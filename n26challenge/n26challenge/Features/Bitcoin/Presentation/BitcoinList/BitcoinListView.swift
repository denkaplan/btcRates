import SwiftUI

struct BitcoinListView: View {
    @ObservedObject var viewModel: BitcoinListViewModel
    @State private var scrollOffset: CGFloat = 0

    private var collapseProgress: CGFloat {
        min(max(-scrollOffset / 96, 0), 1)
    }

    var body: some View {
        VStack(spacing: 0) {
            CollapsibleBitcoinHeader(
                priceText: viewModel.currentPriceText,
                lastUpdatedText: viewModel.lastUpdatedText,
                collapseProgress: collapseProgress
            )
            content
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
        if viewModel.isLoading {
            ProgressView("Loading prices…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.rows.isEmpty, let errorMessage = viewModel.errorMessage {
            ErrorStateView(
                title: "Unable to load Bitcoin prices",
                systemImage: "wifi.exclamationmark",
                message: errorMessage,
                retry: viewModel.retry
            )
        } else {
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("historyScroll")).minY
                    )
                }
                .frame(height: 0)

                LazyVStack(alignment: .leading, spacing: 12, pinnedViews: [.sectionHeaders]) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Section {
                        ForEach(viewModel.rows) { item in
                            HistoryRow(item: item) {
                                viewModel.select(item)
                            }
                        }
                    } header: {
                        Text("Last 14 days")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                            .background(Color(.systemGroupedBackground))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .coordinateSpace(name: "historyScroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
            .refreshable {
                viewModel.retry()
            }
        }
    }
}

private struct CollapsibleBitcoinHeader: View {
    let priceText: String
    let lastUpdatedText: String?
    let collapseProgress: CGFloat

    private var verticalPadding: CGFloat {
        interpolate(from: 24, to: 12)
    }

    private var priceFontSize: CGFloat {
        interpolate(from: 42, to: 24)
    }

    private var titleFont: Font {
        collapseProgress > 0.75 ? .headline : .subheadline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: interpolate(from: 8, to: 4)) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("BTC / EUR")
                    .font(titleFont)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 12)

                if let lastUpdatedText {
                    Text(lastUpdatedText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .opacity(collapseProgress)
                }
            }

            Text(priceText)
                .font(.system(size: priceFontSize, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            if let lastUpdatedText {
                Text(lastUpdatedText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .opacity(1 - collapseProgress)
                    .frame(height: interpolate(from: 18, to: 0), alignment: .top)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, verticalPadding)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
                .opacity(interpolate(from: 0, to: 1))
        }
        .animation(.easeInOut(duration: 0.18), value: collapseProgress)
    }

    private func interpolate(from start: CGFloat, to end: CGFloat) -> CGFloat {
        start + ((end - start) * collapseProgress)
    }
}

private struct HistoryRow: View {
    let item: BitcoinHistoryRowPresentationalModel
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 12)

                Text(item.priceText)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.primary)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
