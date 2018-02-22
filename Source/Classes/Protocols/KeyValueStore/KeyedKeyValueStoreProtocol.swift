//
//  KeyedKeyValueStoreProtocol.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyedKeyValueStoreProtocol: KeyValueStoreProtocol {
    associatedtype Key: KeyExpressible
    func save<Value>(value: Value, for key: Key) throws where Value: Codable
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable
    func deleteValue(for key: Key)
    func deleteAll()
}

//MARK: - Default Implementations forwarding to `KeyValueStoreProtocol` methods
public extension KeyedKeyValueStoreProtocol {
    func save<Value>(value: Value, for key: Key) throws where Value: Codable {
        try save(value: value, forStringKey: key.identifier)
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        return loadValue(forStringKey: key.identifier)
    }
    
    func deleteValue(for key: Key) {
        deleteValue(forStringKey: key.identifier)
    }
}

//MARK: - Convenience Methods
public extension KeyedKeyValueStoreProtocol {
    func string(for key: Key) -> String? {
        return loadValue(for: key)
    }
}
