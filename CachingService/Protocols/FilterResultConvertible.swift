//
//  FilterResultConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol FilterResultConvertible: CustomStringConvertible {
    var filter: FilterConvertible { get }
    var filterable: Filterable { get }
    var keyPaths: [AnyKeyPath] { get }
}

struct FilterResult: FilterResultConvertible {
    let filterable: Filterable
    let keyPaths: [AnyKeyPath]
    let filter: FilterConvertible
    init(_ filter: FilterConvertible, content: Filterable, keyPaths: [AnyKeyPath]) {
        self.filterable = content
        self.filter = filter
        self.keyPaths = keyPaths
    }
}

extension FilterResultConvertible {
    var description: String { return "`\(filterable)` matched query `\(filter)`" }
}
