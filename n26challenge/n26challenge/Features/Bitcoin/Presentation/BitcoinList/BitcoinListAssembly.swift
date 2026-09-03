//
//  BitcoinListAssembly.swift
//  n26challenge
//
//  Created by Kaplan, Deniz on 03.09.26.
//

import SwiftUI
import UIKit

struct BitcoinListAssembly: ModuleAssembly {
    typealias ViewModelType = BitcoinListViewModel
    
    let dependencies: AppDependencyContainer
    let onSelect: (Date) -> (Void)
    
    func assemble() -> Module<BitcoinListViewModel> {
        let viewModel = BitcoinListViewModel(
            getBitcoinHistoryUseCase: dependencies.getBitcoinHistoryUseCase,
            observeBitcoinCurrentPriceUseCase: dependencies.observeBitcoinCurrentPriceUseCase,
            presentationalModelConverter: dependencies.bitcoinListPresentationalModelConverter,
            errorPresentationalModelConverter: dependencies.errorPresentationalModelConverter,
            lastUpdatedTextFormatter: dependencies.lastUpdatedTextFormatter,
            onSelect: { date in
                self.onSelect(date)
            }
        )
        let viewController = UIHostingController(rootView: BitcoinListView(viewModel: viewModel))
        return .init(view: viewController, viewModel: viewModel)
    }
}
