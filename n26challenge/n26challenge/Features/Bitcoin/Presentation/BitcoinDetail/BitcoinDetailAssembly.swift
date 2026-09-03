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
    
    private let date: Date
    private let dependencies: AppDependencyContainer
    
    init(
        dependencies: AppDependencyContainer,
        date: Date
    ) {
        self.date = date
        self.dependencies = dependencies
    }
    
    @MainActor
    func assemble() -> Module<BitcoinDetailViewModel> {
        let viewModel = BitcoinDetailViewModel(
            date: date,
            getDetailPriceUseCase: dependencies.getBitcoinDetailPriceUseCase,
            presentationalModelConverter: dependencies.bitcoinDetailPresentationalModelConverter,
            errorPresentationalModelConverter: dependencies.errorPresentationalModelConverter
        )
        let viewController = UIHostingController(rootView: BitcoinDetailView(viewModel: viewModel))
        viewController.title = DateFormatter.displayDay.string(from: date)
        viewController.navigationItem.largeTitleDisplayMode = .never
        
        return Module(view: viewController, viewModel: viewModel)
    }
}
