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
            case .loaded(let price):
                loaded(price)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            viewModel.onAppear()
        }
    }

    private func loaded(_ price: BitcoinPrice) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DateFormatter.displayDay.string(from: price.date))
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Bitcoin exchange rate")
                        .font(.largeTitle.bold())
                }
                .padding(.vertical, 8)
            }

            Section("Currencies") {
                CurrencyRow(code: "EUR", title: "Euro", value: price.eur, formatter: .eurCurrency)
                CurrencyRow(code: "USD", title: "US Dollar", value: price.usd, formatter: .usdCurrency)
                CurrencyRow(code: "GBP", title: "British Pound", value: price.gbp, formatter: .gbpCurrency)
            }
        }
    }
}

private struct CurrencyRow: View {
    let code: String
    let title: String
    let value: Decimal?
    let formatter: NumberFormatter

    var body: some View {
        HStack(spacing: 12) {
            Text(code)
                .font(.headline.monospaced())
                .frame(width: 48, alignment: .leading)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(formattedValue)
                .font(.body.monospacedDigit())
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }

    private var formattedValue: String {
        guard let value else { return "—" }
        return formatter.string(from: value.asNumber) ?? "\(value)"
    }
}

#Preview {
    BitcoinDetailView(
        viewModel: BitcoinDetailViewModel(
            date: Date(),
            repository: PreviewDetailRepository()
        )
    )
}

private struct PreviewDetailRepository: BitcoinRepository {
    func currentPrice() async throws -> BitcoinPrice {
        BitcoinPrice(date: Date(), eur: 58_000, usd: 63_000, gbp: 49_000)
    }

    func historicalPrices(daysIncludingToday: Int) async throws -> [BitcoinHistoryItem] { [] }

    func details(for date: Date) async throws -> BitcoinPrice {
        BitcoinPrice(date: date, eur: 58_000, usd: 63_000, gbp: 49_000)
    }
}
