//
//  ServiceController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift
import ViewComposer
import SnapKit
import TinyConstraints

final class ServiceViewController: UIViewController {
    let bag = DisposeBag()
    let userService = UserService()
    private var isFetching = false
    
    private lazy var getButton: UIButton = [.text("Get"), .target(self.target(self.getSelector))]
    private lazy var clearButton: UIButton = [.text("Clear Cache"), .target(self.target(self.clearCacheSelector))]
    private lazy var stackView: UIStackView = [.views([self.getButton, self.clearButton]), .axis(.vertical), .distribution(.fillEqually), .verticalMargin(150)]
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not impl")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        getUser()
    }
}

private extension ServiceViewController {
    
    var getSelector: Selector { return #selector(getButtonPressed) }
    var clearCacheSelector: Selector { return #selector(getButtonPressed) }
    
    @objc func getButtonPressed() {
        getUser()
    }
    
    @objc func clearCachePressed() {
        clearCache()
    }
    
    func setupViews() {
        view.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
    func getUser() {
        
        func debugPrint(_ message: String) {
            threadTimePrint("SUBSCRIBER: \(message)")
        }
        
        guard !isFetching else { print("Prevented getUser being called again, since request already is in progress"); return }
        isFetching = true
        userService.getUser(options: RequestPermissions(cache: [.load, .save], backend: [.load, .emitNextEvents, .emitNextEventDirectly])).subscribe(onNext: {
            debugPrint("Got user: `\($0)`")
        }, onError: {
            debugPrint("Error: `\($0)`")
        }, onCompleted: {
            self.isFetching = false
            debugPrint("Completed")
        }, onDisposed: {
            debugPrint("Disposed")
        }).disposed(by: bag)
    }
    
    func clearCache() {
        userService.cache.asyncDeleteValue(for: cacheKeyName) { _ in
            print("deleted")
        }
    }
}

