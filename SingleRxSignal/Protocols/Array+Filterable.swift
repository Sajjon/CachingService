//
//  Array+Filterable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension Array where Element: Filterable {
    
    func match(query: CustomStringConvertible, type: QueryType = .or) -> [QueryResultConvertible] { return matchQuery(Match(type, query: query)) }
    func match(identifiers: [CustomStringConvertible], type: QueryType = .or) -> [QueryResultConvertible] { return matchQuery(Match(identifiers: identifiers, type)) }
    
    func matchQuery(_ query: QueryConvertible) -> [QueryResultConvertible] {
        return flatMap { $0.matches(query) }
    }
    
    func filtered(by filter: QueryConvertible) -> [Element] {
        return matchQuery(filter).flatMap { $0.filterable as? Element }
    }
}
