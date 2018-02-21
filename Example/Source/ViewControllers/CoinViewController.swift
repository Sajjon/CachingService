//
//  CoinViewController.swift
//  Example
//
//  Created by Alexander Cyon on 2018-02-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import UIKit

final class CoinViewController {
    let coinView: CoinView
    init(viewModel: CoinViewModel) {
        coinView = CoinView(viewModel: viewModel)
    }
}

extension CoinViewController: AbstractViewController {
    var rootView: UIView { return coinView }
}
