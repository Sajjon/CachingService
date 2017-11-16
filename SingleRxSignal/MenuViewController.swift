//
//  MenuViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

final class MenuViewController {
    let menuView: MenuView
    init(userService: UserServiceProtocol, presentor: Presentor?) {
       menuView = MenuView(userService: userService, presentor: presentor)
    }
    
    deinit {
        print("deinit of MenuViewController")
    }
}

extension MenuViewController: AbstractViewController {
    var rootView: UIView { return menuView }
}
