//
//  Cache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import Cache

protocol Cache {
    func save<Value>(value: Value, for key: Key) throws where Value: Codable
    func deleteValue(for key: Key)
    func deleteAll()
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable
    func hasValue<Value>(ofType type: Value.Type, for key: Key) -> Bool where Value: Codable
}

extension Cache {
    func saveOrDelete<Value>(optional: Value?, for key: Key) throws where Value: Codable {
        if let value = optional {
           try save(value: value, for: key)
        } else {
            deleteValue(for: key)
        }
    }
}

extension Storage: Cache {
    func save<Value>(value: Value, for key: Key) throws where Value : Decodable, Value : Encodable {
        try setObject(value, forKey: key.identifier)
    }
    
    func deleteValue(for key: Key) {
        try? removeObject(forKey: key.identifier)
    }
    
    func deleteAll() {
        try? self.removeAll()
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value : Decodable, Value : Encodable {
        return try? object(ofType: Value.self, forKey: key.identifier)
    }
    
    func hasValue<Value>(ofType type: Value.Type, for key: Key) -> Bool where Value: Codable {
        do {
            return try existsObject(ofType: type, forKey: key.identifier)
        } catch {
            log.error("Catching storage error: `\(error)`")
            return false
        }
    }
}


