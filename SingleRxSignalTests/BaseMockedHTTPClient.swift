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

class BaseMockedHTTPClient<ValueType: Codable & Equatable> {
    let mockedEvent: MockedEvent<ValueType>
    
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
    func makeRequest<C>() -> Maybe<C> where C: Codable {
        let maybe: Maybe<C>
        
        switch mockedEvent {
        case .error(let error):
            maybe = .error(error)
        case .valueOrEmpty(let maybeValue):
            if let mockedValue = maybeValue.value {
                let value: C = mockedValue as! C
                maybe = .just(value)
            } else {
                maybe = .empty()
            }
        }
        
        return maybe.delay(delay, scheduler: MainScheduler.instance)
    }
}
