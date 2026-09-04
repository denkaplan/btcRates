//
//  ModuleAssembly.swift
//  n26challenge
//
//  Created by Kaplan, Deniz on 03.09.26.
//

import UIKit

struct Module<T> {
    let view: UIViewController
    let viewModel: T
}

protocol ModuleAssembly {
    associatedtype ViewModelType
    @MainActor
    func assemble() -> Module<ViewModelType>
}
