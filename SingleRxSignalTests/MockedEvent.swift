//
//  MockedEvent.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal

enum MockedEvent<Value: Codable & Equatable>: Equatable {
    case valueOrEmpty(ValueOrEmpty<Value>)
    case error(MyError)
}

extension MockedEvent {
    init(_ value: Value?) {
        if let value = value {
            self = .valueOrEmpty(.value(value))
        } else {
            self = .valueOrEmpty(.empty)
        }
    }
    
    init(_ error: MyError) {
        self = .error(error)
    }
    
    static var empty: MockedEvent {
        return .valueOrEmpty(.empty)
    }
    
    var valueOrEmpty: ValueOrEmpty<Value>? {
        switch self {
        case .valueOrEmpty(let valueOrEmpty):
            return valueOrEmpty
        default:
            return nil
        }
    }
    
    var error: MyError? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
}

extension MockedEvent {
    var value: Value? {
        return valueOrEmpty?.value
    }
}

extension MockedEvent {
    static func ==(lhs: MockedEvent, rhs: MockedEvent) -> Bool {
        switch (lhs, rhs) {
        case (.valueOrEmpty(let lhsValueOrEmpty), .valueOrEmpty(let rhsValueOrEmpty)):
            return lhsValueOrEmpty == rhsValueOrEmpty
        case (.error(let lhsError), .error(let rhsError)): return lhsError == rhsError
        default: return false
        }
    }
}

extension MockedEvent: CustomStringConvertible {
    var description: String {
        switch self {
        case .error(let error): return "Error: `\(error)`"
        case .valueOrEmpty(let valueOrEmpty):
            switch valueOrEmpty {
            case .empty: return "Value: EMPTY"
            case .value(let value): return "Value: `\(value)`"
            }
        }
    }
}
