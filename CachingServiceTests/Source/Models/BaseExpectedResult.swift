//
//  BaseExpectedResult.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService

class BaseExpectedResult<Value: Codable & Equatable> {
    var cacheEvent: MockedEvent<Value>
    var httpEvent: MockedEvent<Value>
    
    init(cacheEvent: MockedEvent<Value>, httpEvent: MockedEvent<Value>) {
        self.cacheEvent = cacheEvent
        self.httpEvent = httpEvent
    }
}

extension BaseExpectedResult {
    convenience init(same: Value?) {
        self.init(cacheEvent: MockedEvent(same), httpEvent: MockedEvent(same))
    }

    convenience init(cached: Value?, http: Value?) {
        self.init(cacheEvent: MockedEvent(cached), httpEvent: MockedEvent(http))
    }
    
    convenience init(cacheError: ServiceError, http: Value?) {
        self.init(cacheEvent: MockedEvent(cacheError), httpEvent: MockedEvent(http))
    }
    
    convenience init(cacheError: ServiceError, httpError: ServiceError) {
        self.init(cacheEvent: MockedEvent(cacheError), httpEvent: MockedEvent(httpError))
    }
    
    convenience init(cached: Value?, httpError: ServiceError) {
        self.init(cacheEvent: MockedEvent(cached), httpEvent: MockedEvent(httpError))
    }
}

extension BaseExpectedResult {
    func assertHTTPEquals(_ value: Value?) {
        httpEvent.assertEquals(value)
    }
    
    func assertCacheEquals(_ value: Value?) {
        cacheEvent.assertEquals(value)
    }
}
