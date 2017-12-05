//
//  FilterConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-27.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

enum FilterCompositionType {
    case or, and
}

protocol FilterConvertible: CustomStringConvertible {
    var composition: FilterCompositionType { get }
    var query: CustomStringConvertible? { get }
    var identifiers: [CustomStringConvertible] { get }
    var caseSensitive: Bool { get }
}

extension FilterConvertible {
    var description: String {
        let identifiersString = identifiers.map { $0.description }.joined(separator: ", ")
        let queryString = query?.description ?? ""
        return "\(queryString) [\(identifiersString)]"
    }
}

extension FilterConvertible {
    var casedQuery: String? {
        guard let query = query else { return nil }
        return caseSensitive ? query.description : query.description.lowercased()
    }
}

struct Filter: FilterConvertible {
    let composition: FilterCompositionType
    let query: CustomStringConvertible?
    let identifiers: [CustomStringConvertible]
    let caseSensitive: Bool
    init(identifiers: [CustomStringConvertible] = [], _ composition: FilterCompositionType = .or, query: CustomStringConvertible? = nil, caseSensitive: Bool = false) {
        guard query != nil || !identifiers.isEmpty else { fatalError("empty query") }
        self.identifiers = identifiers
        self.composition = composition
        self.query = query
        self.caseSensitive = caseSensitive
    }
}
