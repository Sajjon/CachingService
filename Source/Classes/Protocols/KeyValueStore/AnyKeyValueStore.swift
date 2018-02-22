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
    
    public func save<Value>(value: Value, forStringKey key: String) throws where Value: Codable {
        try concrete.save(value: value, forStringKey: key)
    }
    
    public func loadValue<Value>(forStringKey key: String) -> Value? where Value: Codable {
        return concrete.loadValue(forStringKey: key)
    }
    
    public func deleteValue(forStringKey key: String) {
        concrete.deleteValue(forStringKey: key)
    }
    
    public func deleteAll() { concrete.deleteAll() }
    
    public var dictionaryRepresentation: [String: Any] { return concrete.dictionaryRepresentation }
}
