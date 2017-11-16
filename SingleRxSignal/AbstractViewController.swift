//
//  AbstractViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit

protocol AbstractViewController: class, Presentable {
    var rootView: UIView { get }
    static var title: String { get }
    func materialize() -> UIViewController
}

extension AbstractViewController {
    static var title: String { return "\(type(of: self))" }
    var title: String { return type(of: self).title }
    
    func materialize() -> UIViewController {
        let viewController = UIViewController()
        viewController.view = rootView
        viewController.title = Self.title
        return viewController
    }
    
}
