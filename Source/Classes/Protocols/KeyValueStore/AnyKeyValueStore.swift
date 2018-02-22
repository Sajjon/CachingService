//
//  AnyKeyValueStore.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public class AnyKeyValueStore: KeyValueStoreProtocol {
    private let concrete: KeyValueStoreProtocol
    public init<Concrete>(_ concrete: Concrete) where Concrete: KeyValueStoreProtocol {
        self.concrete = concrete
    }
    
    public func save<Value>(value: Value, for key: String) throws where Value: Codable {
        try concrete.save(value: value, for: key)
    }
    
    public func loadValue<Value>(for key: String) -> Value? where Value: Codable {
        return concrete.loadValue(for: key)
    }
    
    public func deleteValue(for key: String) {
        concrete.deleteValue(for: key)
    }
    
    public func deleteAll() { concrete.deleteAll() }
    
    public var dictionaryRepresentation: [String: Any] { return concrete.dictionaryRepresentation }
}
