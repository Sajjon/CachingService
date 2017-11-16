//
//  DenendencyInjectionConfigurator.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Swinject

func bootStrapContainer() -> Container {
    return Container() { c in
        c.register(AsyncCache.self) { _ in UserDefaults.standard }.inObjectScope(.container)
        
        c.register(HTTPClientProtocol.self) { _ in HTTPClient() }.inObjectScope(.container)
        
        c.register(UserServiceProtocol.self) { r in
            UserService(
                httpClient: r.resolve(HTTPClientProtocol.self)!,
                cache: r.resolve(AsyncCache.self)!
            )
            }.inObjectScope(.container)
        
        c.register(MenuViewController.self) { (r, presentor: Presentor) in
            MenuViewController(
                userService: r.resolve(UserServiceProtocol.self)!,
                presentor: presentor
            )
        }.inObjectScope(.container)
        
        c.register(MenuViewController.self) { (r, presentor: UINavigationController) in
            MenuViewController(
                userService: r.resolve(UserServiceProtocol.self)!,
                presentor: presentor
            )
            }.inObjectScope(.container)
    }
}
