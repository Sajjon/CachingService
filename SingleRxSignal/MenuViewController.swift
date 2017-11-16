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
    init(userService: UserServiceProtocol, presenter: Presenter?) {
       menuView = MenuView(userService: userService, presenter: presenter)
    }
    
    deinit {
        print("deinit of MenuViewController")
    }
}

extension MenuViewController: AbstractViewController {
    var rootView: UIView { return menuView }
}
