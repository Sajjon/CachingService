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
        try save(value: value, for: key.identifier)
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        return loadValue(for: key.identifier)
    }
    
    func deleteValue(for key: Key) {
        deleteValue(for: key.identifier)
    }
}

//MARK: - Convenience Methods
public extension KeyedKeyValueStoreProtocol {
    func string(for key: Key) -> String? {
        return string(for: key.identifier)
    }
    
    func int(for key: Key) -> Int? {
        return int(for: key.identifier)
    }
    
    func bool(for key: Key) -> Bool? {
        return bool(for: key.identifier)
    }
    
    func float(for key: Key) -> Float? {
        return float(for: key.identifier)
    }
    
    func double(for key: Key) -> Double? {
        return double(for: key.identifier)
    }
}
