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
        if viewModel.isLoading {
            ProgressView("Loading prices…")
                .frame(maxWidth: .infinity, minHeight: 240)
        } else if viewModel.rows.isEmpty, let errorMessage = viewModel.errorMessage {
            ErrorStateView(
                title: "Unable to load Bitcoin prices",
                systemImage: "wifi.exclamationmark",
                message: errorMessage,
                retry: viewModel.retry
            )
            .frame(minHeight: 360)
        } else {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
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

            ForEach(viewModel.rows) { item in
                HistoryRow(item: item) {
                    viewModel.select(item)
                }
            }
        }
    }
}

private struct LivePriceHeader: View {
    let priceText: String
    let lastUpdatedText: String?
    let height: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("BTC / EUR")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))

                Spacer(minLength: 12)

                if let lastUpdatedText {
                    Text(lastUpdatedText)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                }
            }

            Text(priceText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("Live Bitcoin price")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .bottomLeading)
        .padding(.horizontal, 24)
        .padding(.top, 44)
        .padding(.bottom, 22)
        .background(ColorPalette.accentGradient)
        .clipShape(BottomRoundedRectangle(radius: 28))
        .shadow(color: ColorPalette.accent.opacity(0.18), radius: 18, x: 0, y: 10)
    }
}

private struct BottomRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clampedRadius = min(radius, rect.width / 2, rect.height / 2)

        path.move(to: rect.origin)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - clampedRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - clampedRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + clampedRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - clampedRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()

        return path
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
