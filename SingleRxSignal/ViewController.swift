//
//  ViewController.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift

extension Observable {
    func flatMap(emitNextEventBeforeMap emitNextEvent: Bool, mapping: @escaping (E) -> Observable<E>) -> Observable<E> {
        return flatMap { (intermediate: E) -> Observable<E> in
            let mapped = mapping(intermediate)
            guard emitNextEvent else { return mapped }
            return .merge([.of(intermediate), mapped])
        }
    }
}

class ViewController: UIViewController {
    let bag = DisposeBag()
    let userService = UserService()
    override func viewDidLoad() {
        super.viewDidLoad()
        getUser()
    }
    
    func getUser() {
        func debugPrint(_ message: String) {
            threadTimePrint("SUBSCRIBER: \(message)")
        }
        
        userService.getUser(options: RequestPermissions(cache: [.load, .save], backend: [.load, .emitNextEvents, .emitNextEventDirectly])).subscribe(onNext: {
            debugPrint("Got user: `\($0)`")
        }, onError: {
            debugPrint("Error: `\($0)`")
        }, onCompleted: {
            debugPrint("Completed")
        }, onDisposed: {
            debugPrint("Disposed")
        }).disposed(by: bag)
    }
    
    @IBAction func getPressed(_ sender: UIButton) {
        getUser()
    }
    
    @IBAction func clearCachePressed(_ sender: UIButton) {
        userService.cache.asyncDeleteValue(for: cacheKeyName) { _ in
            print("deleted")
        }
    }
}

