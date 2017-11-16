//
//  UserViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

final class UserViewController {
    let userView: UserView
    var presentor: Presentor?
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
