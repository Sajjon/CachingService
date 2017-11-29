//
//  HTTPClient.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-10.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

struct HTTPClient: HTTPClientProtocol {}

protocol HTTPClientProtocol {
    func makeRequest<C>(router: Router) -> Observable<C?> where C: Codable
}

extension HTTPClientProtocol {
    func makeRequest<C>(router: Router) -> Observable<C?> where C: Codable {
        return Observable.create { observer in
            self.makeRequestOnBackground { (model: C?, error: MyError?) in
                defer { observer.onCompleted() }
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(model)
                }
            }
            return Disposables.create()
        }
    }
}

private extension HTTPClientProtocol {
    func makeRequestOnBackground<C>(done: @escaping (C?, MyError?) -> Void) where C: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performRequest(done: done)
        }
    }
    
    func performRequest<C>(done: @escaping (C?, MyError?) -> Void) where C: Codable {
        delay(.http)
        threadTimePrint("Fetching from Backend...type: `\(C.self)`")
        let model: C
        switch FourLevelTypeUnwrapper<C>.fourLevelUnwrappedType {
        case is User.Type:
            model = User(userId: 237, firstName: randomName(), lastName: randomName()) as! C
        case is Group.Type:
            model = Group(name: randomName()) as! C
        default: fatalError("non of the above")
        }
        DispatchQueue.main.async {
            done(model, nil)
        }
    }
}

