//
//  QueryResultConvertible.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol QueryResultConvertible: CustomStringConvertible {
    var query: QueryConvertible { get }
    var filterable: Filterable { get }
    var keyPaths: [AnyKeyPath] { get }
}

struct QueryResult: QueryResultConvertible {
    let filterable: Filterable
    let keyPaths: [AnyKeyPath]
    let query: QueryConvertible
    init(_ query: QueryConvertible, content: Filterable, keyPaths: [AnyKeyPath]) {
        self.filterable = content
        self.query = query
        self.keyPaths = keyPaths
    }
}

extension QueryResultConvertible {
    var description: String { return "`\(filterable)` matched query `\(query)`" }
}
