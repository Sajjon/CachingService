//
//  MenuViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift

final class MenuViewController {
    let menuView: MenuView
    let bag = DisposeBag()
    init(userService: UserServiceProtocol, presenter: Presenter?) {
       menuView = MenuView(userService: userService, presenter: presenter)
    }
}

extension MenuViewController: AbstractViewObservingController {
    var rootView: UIView { return menuView }
    var viewDidLoad: Closure {
        return {
            log.verbose("viewDidLoad from abstract MenuViewController")
        }
    }
    
    var viewWillAppear: Closure {
        return {
            log.verbose("viewWillAppear from abstract MenuViewController")
        }
    }
    
    var viewDidAppear: Closure {
        return {
            log.verbose("viewDidAppear from abstract MenuViewController")
        }
    }
}
