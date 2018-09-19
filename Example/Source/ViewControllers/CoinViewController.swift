//
//  CoinViewController.swift
//  Example
//
//  Created by Alexander Cyon on 2018-02-06.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import UIKit
import CachingService

final class CoinViewController {
    let coinView: CoinView
    init(coin: Coin, coinService: CoinServiceProtocol) {
        coinView = CoinView(coin: coin, coinService: coinService)
    }
}

extension CoinViewController: AbstractViewController {
    var rootView: UIView { return coinView }
}
