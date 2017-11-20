//
//  AbstractViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift
import RxViewController

typealias Closure = () -> Void

protocol AbstractViewController: class, Presentable {
    var rootView: UIView { get }
    static var title: String { get }
    func materialize() -> UIViewController
    func bindViewControllerLifeCycleMethods(to: UIViewController)
}

protocol ViewLifeCycleObserver {
    var bag: DisposeBag { get }
    var viewDidLoad: Closure { get }
    var viewWillAppear: Closure { get }
    var viewDidAppear: Closure { get }
}

extension AbstractViewController {

    func materialize() -> UIViewController {
        let viewController = UIViewController()
        bindViewControllerLifeCycleMethods(to: viewController)
        viewController.abstract = self
        viewController.title = Self.title
        viewController.view.addSubview(rootView)
        rootView.edgesToSuperview()
        return viewController
    }
    
    func bindViewControllerLifeCycleMethods(to: UIViewController) {}
}

typealias AbstractViewObservingController = AbstractViewController & ViewLifeCycleObserver
extension AbstractViewController where Self: ViewLifeCycleObserver {
    func bindViewControllerLifeCycleMethods(to viewController: UIViewController) {
        viewController.rx.viewDidLoad.subscribe() { [weak self] _ in
            self?.viewDidLoad()
        }.disposed(by: bag)
        
        viewController.rx.viewWillAppear.subscribe() { [weak self] _ in
            self?.viewWillAppear()
        }.disposed(by: bag)
        
        viewController.rx.viewDidAppear.subscribe() { [weak self] _ in
            self?.viewDidAppear()
        }.disposed(by: bag)
    }
}

extension ViewLifeCycleObserver {
    var viewDidLoad: Closure { return {} }
    var viewWillAppear: Closure { return {} }
    var viewDidAppear: Closure { return {} }
}

extension AbstractViewController {
    static var title: String { return "\(type(of: self))" }
    var title: String { return type(of: self).title }
}
