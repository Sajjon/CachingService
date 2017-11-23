//
//  BaseMockedHTTPClient.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import SingleRxSignal
import RxSwift
import SwiftyBeaver

class BaseMockedHTTPClient<ValueType: Codable & Equatable> {
    var mockedEvent: MockedEvent<ValueType>
    
    private let delay: RxTimeInterval
    
    init(
        mockedEvent: MockedEvent<ValueType>,
        delay: RxTimeInterval = 0.02
        ) {
        self.mockedEvent = mockedEvent
        self.delay = delay
    }
}

extension BaseMockedHTTPClient: HTTPClientProtocol {
    func makeRequest<C>() -> Observable<C?> where C: Codable {
        log.verbose("Start")
        return Observable.create { observer in
            switch self.mockedEvent {
            case .error(let error):
                observer.onError(error)
            case .valueOrEmpty(let valueOrEmpty):
                switch valueOrEmpty {
                case .empty: observer.onNext(nil)
                case .value(let value): observer.onNext(value as! C)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }.delay(delay, scheduler: MainScheduler.instance)
    }
}

extension BaseMockedHTTPClient {
    var mockedValue: ValueType? {
        return mockedEvent.value
    }
}
