//
//  Presentor.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

protocol Presentor {
    func present(_ presentable: Presentable , presentation: Presentation)
}

extension UINavigationController: Presentor {}

extension Presentor where Self: UINavigationController {
    func present(_ presentable: Presentable , presentation: Presentation) {
        guard let abstractViewController = presentable as? AbstractViewController else { fatalError("Unsupported presentable") }
        let viewController = abstractViewController.materialize()
        switch presentation.style {
        case .modal(let completion): self.present(viewController, animated: presentation.animated, completion: completion)
        case .push: self.pushViewController(viewController, animated: presentation.animated)
        }
    }
}
