//
//  FilterResultConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol FilterResultConvertible: CustomStringConvertible {
    var filter: FilterConvertible { get }
    var filterable: Filterable { get }
    var keyPaths: [AnyKeyPath] { get }
}

public struct FilterResult: FilterResultConvertible {
    public let filterable: Filterable
    public let keyPaths: [AnyKeyPath]
    public let filter: FilterConvertible
    public init(_ filter: FilterConvertible, content: Filterable, keyPaths: [AnyKeyPath]) {
        self.filterable = content
        self.filter = filter
        self.keyPaths = keyPaths
    }
}

public extension FilterResultConvertible {
    var description: String { return "`\(filterable)` matched query `\(filter)`" }
}
