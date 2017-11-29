//
//  MockedCacheForUser.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-29.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal

final class MockedCacheForUser: BaseMockedCache<List<User>> {
    init(mockedEvent: MockedEvent<List<User>>) {
        super.init(event: mockedEvent)
    }
    
    override func save<_Value>(value: _Value, for key: Key) throws where _Value: Codable {
        guard mockedSavingError == nil else { throw mockedSavingError! }
        cachedEvent = MockedEvent(value as! List<User>)
    }
    
    override func loadValue<_Value>(for key: Key) -> _Value? where _Value: Codable {
        guard let cachedValue = mockedValue else { return nil }
        if _Value.self == (Array<User>.self).self {
            return cachedValue.elements as! _Value
        } else {
            return cachedValue as! _Value
        }
    }
    
}
