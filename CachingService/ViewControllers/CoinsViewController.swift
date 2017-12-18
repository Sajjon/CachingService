//
//  CoinsViewController.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

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
    
    deinit { log.debug("") }
}

extension CoinsViewController: AbstractViewController {
    var rootView: UIView { return coinsView }
}


final class CoinViewController {
    let coinView: CoinView
    init(viewModel: CoinViewModel) {
        coinView = CoinView(viewModel: viewModel)
    }
    
    deinit { log.debug("") }
}

extension CoinViewController: AbstractViewController {
    var rootView: UIView { return coinView }
}
