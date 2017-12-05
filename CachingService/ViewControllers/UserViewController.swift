//
//  UserViewController.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

final class UserViewController {
    let userView: UserView
    init(userService: UserServiceProtocol) {
        userView = UserView(userService: userService)
    }
    
    deinit {
        print("deinit of UserViewController")
    }
}

extension UserViewController: AbstractViewController {    
    var rootView: UIView { return userView }
}

final class CoinsViewController {
    let coinsView: CoinsView
    init(
        coinService: CoinServiceProtocol,
        imageService: ImageService,
        presenter: Presenter?
        ) {
        coinsView = CoinsView(
            coinService: coinService,
            imageService: imageService,
            presenter: presenter
        )
    }
    
    deinit {
        print("deinit of CoinsViewController")
    }
}

extension CoinsViewController: AbstractViewController {
    var rootView: UIView { return coinsView }
}
