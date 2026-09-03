# Bitcoin price

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


## Architecture

Clean MVVM + Coordinator.
The project uses SwiftUI for screens and UIKit for routing.
App Represents Feature Based Architecture.

Features: 
- `Bitcoin` - Domain that has a List and Detail screen showing Bitcoin price.
