//
//  MockedCacheForInteger.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

enum ValueOrEmpty<Value: Equatable>: Equatable {
    case value(Value)
    case empty
}

extension ValueOrEmpty {
    static func ==(lhs: ValueOrEmpty<Value>, rhs: ValueOrEmpty<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.value(let lhsValue), .value(let rhsValue)): return lhsValue == rhsValue
        case (.empty, .empty): print(".empty == .empty?? Defining as `false`"); return false
        default: return false
        }
    }
}

extension ValueOrEmpty {
    var value: Value? {
        switch self {
        case .value(let value):
            return value
        default:
            return nil
        }
    }
}

final class MockedCacheForInteger: BaseMockedCache<Int> {
    init(mockedEvent: MockedEvent<Int>) {
        super.init(event: mockedEvent)
    }
}
