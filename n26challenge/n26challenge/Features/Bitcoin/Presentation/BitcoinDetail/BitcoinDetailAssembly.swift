//
//  BitcoinDetailAssembly.swift
//  n26challenge
//
//  Created by Kaplan, Deniz on 03.09.26.
//

import UIKit
import SwiftUI

struct BitcoinDetailAssembly: ModuleAssembly {
    typealias ViewModelType = BitcoinDetailViewModel

    private let initialHistoryRow: BitcoinHistoryRowPresentationalModel
    private let dependencies: AppDependencyContainer

    init(
        dependencies: AppDependencyContainer,
        initialHistoryRow: BitcoinHistoryRowPresentationalModel
    ) {
        self.initialHistoryRow = initialHistoryRow
        self.dependencies = dependencies
    }

    @MainActor
    func assemble() -> Module<BitcoinDetailViewModel> {
        let viewModel = BitcoinDetailViewModel(
            initialHistoryRow: initialHistoryRow,
            getDetailPriceUseCase: dependencies.getBitcoinDetailPriceUseCase,
            presentationalModelConverter: dependencies.bitcoinDetailPresentationalModelConverter,
            errorPresentationalModelConverter: dependencies.errorPresentationalModelConverter
        )
        let viewController = UIHostingController(rootView: BitcoinDetailView(viewModel: viewModel))
        viewController.title = initialHistoryRow.title
        viewController.navigationItem.largeTitleDisplayMode = .never

        return Module(view: viewController, viewModel: viewModel)
    }
}
