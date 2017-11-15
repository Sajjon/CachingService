//
//  BaseExpectedResult.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal

class BaseExpectedResult<Value: Codable> {
    let cacheValue: Value?
    let httpEvent: MockedEvent<Value>
    
    init(cacheValue: Value?, httpEvent: MockedEvent<Value>) {
        self.cacheValue = cacheValue
        self.httpEvent = httpEvent
    }
}

extension BaseExpectedResult {
    convenience init(lastRun: BaseExpectedResult, permissions: RequestPermissions) {
        self.init(
            cacheValue: lastRun.cacheValueForNextRunFrom(permissions),
            httpEvent: lastRun.httpEventForNextRunFrom(permissions)
        )
    }
}

private extension BaseExpectedResult {
    func cacheValueForNextRunFrom(_ p: RequestPermissions) -> Value? {
        var next: Value? = nil
        guard p.shouldLoadFromCache else {
            if p.shouldSaveToCache { next = httpEvent.value }
            print("Case0")
            return next
        }
        
        switch (p.shouldFetchFromBackend, p.shouldSaveToCache, cacheValue, httpEvent) {
        case (true, true, _, .value(let httpValue)): next = httpValue ?? (cacheValue ?? nil); print("Case1")
        case (true, true, .some(let cache), .error(_)): next = cache; print("Case2")
        case (_, false, .some(let cache), _): next = cache; print("Case3")
        default: print("Include this case: (shouldFetchFromBackend: \(p.shouldFetchFromBackend), shouldSaveToCache: \(p.shouldSaveToCache), cache: \(cacheValue), http: \(httpEvent)"); fatalError("killed")
        }
        return next
    }
    
    func httpEventForNextRunFrom(_ p: RequestPermissions) -> MockedEvent<Value> {
        guard p.shouldFetchFromBackend else { return MockedEvent.value(nil) }
        return httpEvent
    }
}

