//
//  Filterable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-27.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//
import Foundation
protocol Filterable {
    func isMatching(_ filter: FilterConvertible) -> FilterResultConvertible?
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
    
    func isMatching(_ filter: FilterConvertible) -> FilterResultConvertible? {
        let keyPathsMatching = keyPathsMatchingQuery(filter)
        let primaryKeyPath: AnyKeyPath! = primaryKeyPathMatchingIdentifiers(filter)
        
        var keyPaths: [AnyKeyPath]?
        
        switch (primaryKeyPath != nil, filter.composition, !keyPathsMatching.isEmpty) {
        case (true, .or, false): keyPaths = [primaryKeyPath]
        case (false, .or, true): keyPaths = keyPathsMatching
        case (true, _, true): keyPaths = keyPathsMatching + [primaryKeyPath]
        default: break
        }
        
        guard let paths = keyPaths else { return nil }
        return FilterResult(filter, content: self, keyPaths: paths)
    }
}

private extension Filterable {
    func keyPathsMatchingQuery(_ filter: FilterConvertible) -> [AnyKeyPath] {
        return keyPaths.filter { value(at: $0).containsQuery(in: filter) }
    }
    
    func primaryKeyPathMatchingIdentifiers(_ filter: FilterConvertible) -> AnyKeyPath? {
        let identifiers = filter.identifiers
        guard
            let primaryKeyPath = primaryKeyPath,
            let identifier = self[keyPath: primaryKeyPath] as? CustomStringConvertible,
            !identifiers.filter({ $0.description == identifier.description }).isEmpty
            else { return nil }
        return primaryKeyPath
    }
}

private extension Filterable {
    
    func value(at path: AnyKeyPath) -> CustomStringConvertible? {
        return self[keyPath: path] as? CustomStringConvertible
    }
}

private extension Optional where Wrapped == CustomStringConvertible {
    func containsQuery(in filter: FilterConvertible) -> Bool {
        guard let query = filter.query, case let .some(wrapped) = self else { return false }
        return query.contains(wrapped, caseSensitive: filter.caseSensitive)
    }
}

extension Filterable {
    func isMatching(query: CustomStringConvertible) -> FilterResultConvertible? {
        return isMatching(Filter(query: query))
    }
}

