# Bitcoin price

Small iPhone app for the N26 coding challenge. It fetches Bitcoin exchange rates from the CoinGecko API and shows:

- a BTC/EUR history list for the last 14 days, including today
- a live BTC/EUR header refreshed every 60 seconds
- a detail screen with BTC prices in EUR, USD and GBP for the selected day

## Requirements

- Xcode 16 or newer
- iOS 15 minimum deployment target
- Network access to `https://api.coingecko.com`

## How to run

1. Open `n26challenge/n26challenge.xcodeproj` in Xcode.
2. Select the `n26challenge` scheme.
3. Run on an iPhone simulator or device.

## Tests

Run unit tests from Xcode with `Cmd+U`, or from the terminal:

```bash
xcodebuild test -project n26challenge/n26challenge.xcodeproj -scheme n26challenge -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:n26challengeTests
```

## API note

The app uses CoinGecko public endpoints. CoinGecko has a strict rate-limit policy, so the app intentionally keeps network usage modest:

- current price polling runs every 60 seconds
- pull-to-refresh restarts the current-price observation and reloads history
- user-facing rate-limit messaging is mapped from HTTP `429`

If requests are rate-limited, wait briefly and retry.

## High-level architecture

The app follows a feature-based Clean MVVM + Coordinator structure.

### App layer

- `AppDelegate` configures UIKit scene lifecycle.
- `SceneDelegate` creates the window, dependency container and root coordinator.
- `AppDependencyContainer` builds the dependency graph once and injects concrete implementations into assemblies.
- `Coordinator` is the base class for UIKit navigation flows.

### Feature layer

The Bitcoin feature is split into:

- `Domain`
  - domain values such as `Price`, `HistoryPrice`, `Currency` and `CryptoCoin`
  - repository contract `BitcoinRepository`
  - use cases for history, detail price loading and current-price observation
- `Data`
  - `CoingeckoBitcoinRepositoryImpl`
  - `CoingeckoEndpoint`
  - CoinGecko response DTOs
- `Presentation`
  - SwiftUI views
  - view models
  - module assemblies
  - presentation model converters
  - reusable feature components

### Routing

UIKit owns navigation and SwiftUI owns rendering:

```text
AppCoordinator
  -> BitcoinListCoordinator
      -> BitcoinDetailCoordinator
```

List and detail modules are created by their assemblies. The list coordinator passes the selected list row into the detail coordinator.

### Detail fallback behavior

The list already has the selected day's EUR price. That selected history row is injected into the detail screen so the user immediately sees EUR data.

The detail screen then refreshes full EUR/USD/GBP data. If the refresh fails, the fallback EUR data remains visible and an inline retry error is shown below it, allowing the user to retry loading the full detail data.

### Shared layer

- `Shared/Data` contains the app's lightweight networking transport.
- `Shared/Presentation` contains shared presentation primitives such as color palette and error presentation mapping.
- `Support` contains date, calendar and formatter helpers.

No third-party frameworks are used.
