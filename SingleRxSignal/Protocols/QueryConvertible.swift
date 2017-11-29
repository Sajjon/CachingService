//
//  QueryConvertible.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-27.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

enum QueryType {
    case or, and
}

protocol QueryConvertible: CustomStringConvertible {
    var type: QueryType { get }
    var query: CustomStringConvertible? { get }
    var identifiers: [CustomStringConvertible] { get }
    var caseSensitive: Bool { get }
}

extension QueryConvertible {
    var description: String {
        let identifiersString = identifiers.map { $0.description }.joined(separator: ", ")
        let queryString = query?.description ?? ""
        return "\(queryString) [\(identifiersString)]"
    }
}

extension QueryConvertible {
    var casedQuery: String? {
        guard let query = query else { return nil }
        return caseSensitive ? query.description : query.description.lowercased()
    }
}

extension QueryConvertible {
    
    
    func queryContained(in other: CustomStringConvertible?) -> Bool {
        guard let query = query, let other = other else { return false }
        return query.contains(other, caseSensitive: caseSensitive)
    }
}

struct Match: QueryConvertible {
    let type: QueryType
    let query: CustomStringConvertible?
    let identifiers: [CustomStringConvertible]
    let caseSensitive: Bool
    init(identifiers: [CustomStringConvertible] = [], _ type: QueryType = .or, query: CustomStringConvertible? = nil, caseSensitive: Bool = false) {
        guard query != nil || !identifiers.isEmpty else { fatalError("empty query") }
        self.identifiers = identifiers
        self.type = type
        self.query = query
        self.caseSensitive = caseSensitive
    }
}
