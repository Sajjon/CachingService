//
//  Int+StaticKeyConvertible.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import SingleRxSignal

extension Int: StaticKeyConvertible {
    public static var key: Key { return "integer" }
}
