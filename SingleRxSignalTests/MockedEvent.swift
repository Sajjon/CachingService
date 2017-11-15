//
//  MockedEvent.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal

enum MockedEvent<Value: Codable> {
    case value(Value?)
    case error(MyError)
    
    var value: Value? {
        switch self {
        case .value(let value):
            return value
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

extension MockedEvent: CustomStringConvertible {
    var description: String {
        if let value = value {
            return "Value: `\(value)`"
        }
        if let error = error {
            return "Error: `\(error)`"
        }
        fatalError("incorrect implementation")
    }
}
