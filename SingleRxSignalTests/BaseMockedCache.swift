//
//  BaseMockedCache.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal

class BaseMockedCache<ValueType: Codable>: AsyncCache {
    var cached: ValueType?
    
    init(cached: ValueType?) {
        self.cached = cached
    }
    
    func save<Value>(value: Value, for key: Key) throws where Value: Codable {
        print("mocking saving")
        cached = (value as! ValueType)
    }
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        print("mocking loading")
        guard let saved = cached else { return nil }
        let casted: Value = saved as! Value
        return casted
    }
    func hasValue(for key: Key) -> Bool { return cached != nil }
    func deleteValue(for key: Key) { cached = nil }
    
}
