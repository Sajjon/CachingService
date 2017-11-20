//
//  AppDelegate.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift
import Swinject


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let container: Container = DenendencyInjectionConfigurator.registerDependencies()
    func applicationDidFinishLaunching(_ application: UIApplication) {
        window = bootStrap()
    }
}

private extension AppDelegate {
    func bootStrap() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(MenuViewController.self, in: container)
        window.makeKeyAndVisible()
        return window
    }
}

extension UINavigationController {
    convenience init<A>(abstract: A) where A: AbstractViewController {
        self.init(rootViewController: abstract.materialize())
    }
    
    convenience init<A>(_ abstractType: A.Type, in container: Container) where A: AbstractViewController {
        self.init(nibName: nil, bundle: nil)
        if let abstract = container.resolve(abstractType, argument: self) {
            viewControllers = [abstract.materialize()]
        }
    }
}
