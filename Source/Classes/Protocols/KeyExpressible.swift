//
//  KeyExpressible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyExpressible {
    var identifier: String { get }
}

public extension KeyExpressible {
    var prefix: String? { return nil }
}

public extension KeyExpressible where Self: RawRepresentable, Self.RawValue == String {
    var identifier: String {
        guard let prefix = prefix else { return rawValue }
        return "\(prefix)_\(rawValue)"
    }
}
