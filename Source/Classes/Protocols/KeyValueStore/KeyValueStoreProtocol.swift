//
//  KeyValueStoreProtocol.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol KeyValueStoreProtocol: class {
    func save<Value>(value: Value, forStringKey key: String) throws where Value: Codable
    func loadValue<Value>(forStringKey key: String) -> Value? where Value: Codable
    func deleteValue(forStringKey key: String)
    func deleteAll()
    var dictionaryRepresentation: [String: Any] { get }
}
