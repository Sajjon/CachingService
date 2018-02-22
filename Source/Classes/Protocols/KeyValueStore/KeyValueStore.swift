//
//  KeyValueStore.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public class KeyValueStore<K: KeyExpressible>: KeyedKeyValueStoreProtocol {
    
    public typealias Key = K
    private let _box: _KeyValueStoreBase<Key>
    
    public init<Container: KeyedKeyValueStoreProtocol>(_ container: Container) where Container.Key == Key {
        _box = _KeyValueStoreBox(container)
    }
}

public extension KeyValueStore {
    func save<Value>(value: Value, forStringKey key: String) throws where Value: Codable { try _box.save(value: value, forStringKey: key) }
    func loadValue<Value>(forStringKey key: String) -> Value? where Value: Codable { return _box.loadValue(forStringKey: key) }
    func deleteValue(forStringKey key: String) { _box.deleteValue(forStringKey: key) }
    func deleteAll() { _box.deleteAll() }
    var dictionaryRepresentation: [String : Any] { return _box.dictionaryRepresentation }
}

private final class _KeyValueStoreBox<Concrete: KeyedKeyValueStoreProtocol>: _KeyValueStoreBase<Concrete.Key> {
    typealias Key = Concrete.Key
    private let concrete: Concrete
    
    init(_ container: Concrete) {
        concrete = container
    }
    
    override func save<Value>(value: Value, forStringKey key: String) throws where Value: Codable { try concrete.save(value: value, forStringKey: key) }
    override func loadValue<Value>(forStringKey key: String) -> Value? where Value: Codable { return concrete.loadValue(forStringKey: key) }
    override func deleteValue(forStringKey key: String) { concrete.deleteValue(forStringKey: key) }
    override func deleteAll() { concrete.deleteAll() }
    override var dictionaryRepresentation: [String : Any] { return concrete.dictionaryRepresentation }
}


public var abstract: Never { fatalError("Must be overridden") }
private class _KeyValueStoreBase<Key: KeyExpressible> {
    func save<Value>(value: Value, forStringKey key: String) throws where Value: Codable { abstract }
    func loadValue<Value>(forStringKey key: String) -> Value? where Value: Codable { abstract }
    func deleteValue(forStringKey key: String) { abstract }
    func deleteAll() { abstract }
    var dictionaryRepresentation: [String : Any] { abstract }
}

