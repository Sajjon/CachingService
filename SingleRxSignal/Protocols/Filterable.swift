//
//  Filterable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-27.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol Filterable {
    func matches(_ query: QueryConvertible) -> QueryResultConvertible?
    static var primaryKeyPath: AnyKeyPath? { get }
    static var keyPaths: [AnyKeyPath] { get }
}

// Convenience
extension Filterable {
    var primaryKeyPath: AnyKeyPath? { return Self.primaryKeyPath }
    var keyPaths: [AnyKeyPath] { return Self.keyPaths }
}

// Default implementation
extension Filterable {
    // Making primaryKeyPath `optional`
    static var primaryKeyPath: AnyKeyPath? { return nil }
    
    func matches(_ query: QueryConvertible) -> QueryResultConvertible? {
        let matchFromQuery = matchesQuery(query)
        let matchFromIdentifiers = matchesAny(query.identifiers)
        
        switch query.type {
        case .or:
            guard let matchFromIdentifiers = matchFromIdentifiers else {
                guard !matchFromQuery.isEmpty else { return nil }
                return QueryResult(query, content: self, keyPaths: matchFromQuery)
            }
            let combined: [AnyKeyPath] = matchFromQuery + [matchFromIdentifiers]
            guard !combined.isEmpty else { return nil }
            return QueryResult(query, content: self, keyPaths: combined)
        case .and:
            guard !matchFromQuery.isEmpty, let matchFromIdentifiers = matchFromIdentifiers else { return nil }
            let combined: [AnyKeyPath] = matchFromQuery + [matchFromIdentifiers]
            guard !combined.isEmpty else { return nil }
            return QueryResult(query, content: self, keyPaths: combined)
        }
    }
}

private extension Filterable {
    
    func matchesQuery(_ query: QueryConvertible) -> [AnyKeyPath] {
        return keyPaths.filter { query.queryContained(in: self[filterablePath: $0]) }
    }
    
    func matchesAny(_ identifiers: [CustomStringConvertible]) -> AnyKeyPath? {
        guard
            let primaryKeyPath = primaryKeyPath,
            let identifier = self[keyPath: primaryKeyPath] as? CustomStringConvertible,
            !identifiers.filter({ $0.description == identifier.description }).isEmpty
            else { return nil }
        return primaryKeyPath
    }
}

extension Filterable {
    subscript(filterablePath path: AnyKeyPath) -> CustomStringConvertible? {
        return self[keyPath: path] as? CustomStringConvertible
    }
}

extension Filterable {
    func matches(query: CustomStringConvertible) -> QueryResultConvertible? {
        return matches(Match(query: query))
    }
}
