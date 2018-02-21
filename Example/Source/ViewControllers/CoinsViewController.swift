//
//  CoinsViewController.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import CachingService

final class CoinsViewController {
    let coinsView: CoinsView
    init(
        coinService: CoinServiceProtocol,
        imageService: ImageServiceProtocol,
        presenter: Presenter?
        ) {
        coinsView = CoinsView(
            coinService: coinService,
            imageService: imageService,
            presenter: presenter
        )
    }
}

extension CoinsViewController: AbstractViewController {
    var rootView: UIView { return coinsView }
    static var title: String { return "Coins and tokens" }
}


