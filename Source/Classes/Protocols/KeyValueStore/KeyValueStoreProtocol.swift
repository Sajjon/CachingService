//
//  KeyValueStoreProtocol.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyValueStoreProtocol: class {
    func save<Value>(value: Value, for key: String) throws where Value: Codable
    func loadValue<Value>(for key: String) -> Value? where Value: Codable
    func deleteValue(for key: String)
    func deleteAll()
    var dictionaryRepresentation: [String: Any] { get }
}

//MARK: - Convenience Methods
public extension KeyValueStoreProtocol {
    func string(for key: String) -> String? {
        guard let value: String = loadValue(for: key) else { return nil }
        return value
    }
    
    func int(for key: String) -> Int? {
        guard let value: Int = loadValue(for: key) else { return nil }
        return value
    }
    
    func bool(for key: String) -> Bool? {
        guard let value: Bool = loadValue(for: key) else { return nil }
        return value
    }
    
    func float(for key: String) -> Float? {
        guard let value: Float = loadValue(for: key) else { return nil }
        return value
    }
    
    func double(for key: String) -> Double? {
        guard let value: Double = loadValue(for: key) else { return nil }
        return value
    }
}

public extension KeyValueStoreProtocol {
    func hasString(for key: String) -> Bool {
        return string(for: key) != nil
    }
    
    func hasInt(for key: String) -> Bool {
        return int(for: key) != nil
    }
    
    func hasBool(for key: String) -> Bool {
        return bool(for: key) != nil
    }
    
    func hasFloat(for key: String) -> Bool {
        return float(for: key) != nil
    }
    
    func hasDouble(for key: String) -> Bool {
        return double(for: key) != nil
    }
}
