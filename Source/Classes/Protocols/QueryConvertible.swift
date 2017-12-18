//
//  FilterConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-27.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public enum FilterCompositionType {
    case or, and
}

public protocol FilterConvertible: CustomStringConvertible {
    var composition: FilterCompositionType { get }
    var query: CustomStringConvertible? { get }
    var identifiers: [CustomStringConvertible] { get }
    var caseSensitive: Bool { get }
}

public extension FilterConvertible {
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

public struct Filter: FilterConvertible {
    public let composition: FilterCompositionType
    public let query: CustomStringConvertible?
    public let identifiers: [CustomStringConvertible]
    public let caseSensitive: Bool
    public init(identifiers: [CustomStringConvertible] = [], _ composition: FilterCompositionType = .or, query: CustomStringConvertible? = nil, caseSensitive: Bool = false) {
        guard query != nil || !identifiers.isEmpty else { fatalError("empty query") }
        self.identifiers = identifiers
        self.composition = composition
        self.query = query
        self.caseSensitive = caseSensitive
    }
}
