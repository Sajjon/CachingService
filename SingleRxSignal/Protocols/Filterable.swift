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
        let matchFromIdentifiers: AnyKeyPath! = matchesAny(query.identifiers)
        
        var keyPaths: [AnyKeyPath]? = nil
        
        switch (matchFromIdentifiers != nil, query.type, !matchFromQuery.isEmpty) {
        case (true, .or, false): keyPaths = [matchFromIdentifiers]
        case (false, .or, true): keyPaths = matchFromQuery
        case (true, _, true): keyPaths = matchFromQuery + [matchFromIdentifiers]
        default: break
        }
        
        guard let paths = keyPaths else { return nil }
        return QueryResult(query, content: self, keyPaths: paths)
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
