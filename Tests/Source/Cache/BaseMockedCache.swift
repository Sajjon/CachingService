//
//  BaseMockedCache.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
import SwiftyBeaver

class BaseMockedCache<Value: Codable & Equatable>: AsyncCache {
    func deleteAll() {
        cachedEvent = .empty
    }
    
    var cachedEvent: MockedEvent<Value>
    
    init(event: MockedEvent<Value>) {
        self.cachedEvent = event
    }
    
    func save<_Value>(value: _Value, for key: Key) throws where _Value: Codable {
        log.verbose("Start")
        guard mockedSavingError == nil else { throw mockedSavingError! }
        let cachedValue: Value = (value as! Value)
        cachedEvent = MockedEvent(cachedValue)
    }
    
    func loadValue<_Value>(for key: Key) -> _Value? where _Value: Codable {
        log.verbose("Start")
        guard let cachedValue = mockedValue else { return nil }
        let casted: _Value = cachedValue as! _Value
        return casted
    }
    
    func hasValue<Value>(ofType type: Value.Type, for key: Key) -> Bool { return mockedValue != nil }
    
    func deleteValue(for key: Key) {
        log.verbose("Start")
        cachedEvent = .empty
    }
}

extension BaseMockedCache {
    var mockedSavingError: ServiceError? {
        guard case let .error(error) = cachedEvent else { return nil }
        return error
    }
    
    var mockedValue: Value? {
        return cachedEvent.value
    }
}
