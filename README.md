# n26challenge

Small iPhone app for the N26 coding challenge. It fetches the Bitcoin exchange rate from the CoinGecko API and shows:

- a list of BTC/EUR prices for the last 14 days, including today
- a live BTC/EUR header that refreshes every 60 seconds
- a detail screen with BTC prices in EUR, USD and GBP for the selected day

## Requirements

- Xcode 16 or newer
- iOS 15 minimum deployment target
- Network access to `https://api.coingecko.com`

## How to run

1. Open `n26challenge/n26challenge.xcodeproj` in Xcode.
2. Select the `n26challenge` scheme.
3. Run on an iPhone simulator or device.

The app is self-contained; networking transport primitives live in `n26challenge/n26challenge/Shared/Data`.

## Tests

Run unit tests from Xcode with `Cmd+U`, or from the terminal:

```bash
xcodebuild test -project n26challenge/n26challenge.xcodeproj -scheme n26challenge -destination 'platform=iOS Simulator,name=iPhone 16'
```

If your installed simulator has a different name, replace `iPhone 16` with one listed by:

```bash
xcrun simctl list devices available
```

## Architecture

The project uses SwiftUI for screens and UIKit for routing:

- `AppDelegate` provides the UIKit scene configuration.
- `SceneDelegate` creates the per-scene window, root dependency graph and app coordinator.
- `App/Coordinator` is a base class with default child-coordinator retention and cleanup.
- `AppCoordinator` bootstraps the root `UINavigationController` and starts the Bitcoin list flow.
- `BitcoinListCoordinator` owns the list screen and routes selected days to details.
- `BitcoinDetailCoordinator` owns detail presentation and releases itself when its screen is popped.
- `AppDependencyContainer` wires concrete dependencies once at app startup.
- `Features/Bitcoin/Domain` contains domain models, the repository contract and use cases.
- `GetBitcoinHistoryUseCase` owns the 14-day range calculation, daily grouping and descending sorting.
- `ObserveBitcoinCurrentPriceUseCase` exposes a Task-backed `AsyncStream` that emits immediately and then every 60 seconds.
- `GetBitcoinDetailPriceUseCase` decides whether a selected day should use live or historical pricing.
- `Features/Bitcoin/Data/CoingeckoBitcoinRepository` stays lightweight: it only calls CoinGecko endpoints and maps DTOs to domain models.
- Presentation converters transform Domain prices into ready-to-render presentation models containing strings.
- `BitcoinListViewModel` loads history through `GetBitcoinHistoryUseCase`, observes live prices through `ObserveBitcoinCurrentPriceUseCase`, merges today’s live price, and exposes presentation models.
- `BitcoinListView` and `BitcoinDetailView` are lightweight SwiftUI views that render preformatted presentation models.

No third-party frameworks are used. `Shared/Data` provides the app networking transport primitives (`NetworkProvider`, `NetworkConfiguration`, endpoints and network errors).
