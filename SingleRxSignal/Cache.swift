//
//  Cache.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

protocol Cache {
    func save<Value>(value: Value, for key: Key) throws where Value: Codable
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable
    func deleteValue<Value>(for key: Key) -> Value? where Value: Codable
    func hasValue(for key: Key) -> Bool
}

enum Result<C> {
    case success(C)
    case error(MyError)
}

typealias Done<C> = (Result<C>) -> Void
var void: () { () }
protocol AsyncCache: Cache {
    func asyncSave<Value>(value: Value, for key: Key, done: @escaping Done<Void>) where Value: Codable
    func asyncLoadValue<Value>(for key: Key, done: @escaping Done<Value>) where Value: Codable
    func asyncDeleteValue<Value>(for key: Key, done: @escaping Done<Value?>) where Value: Codable
    func asyncHasValue(for key: Key, done: @escaping Done<Bool>)
}

extension UserDefaults: AsyncCache {}

protocol Key {
    var identifier: String { get }
}
extension String: Key {
    var identifier: String {
        return self
    }
}

//MARK: - Caching
extension UserDefaults {
    func save<Value>(value: Value, for key: Key) throws where Value: Codable {
        threadTimePrint("Cache: saving...")
        simulateCacheDelay()
        let data = try JSONEncoder().encode([value])
        set(data, forKey: key.identifier)
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        threadTimePrint("Cache: loading...")
        simulateCacheDelay()
        guard
            let loadedData = data(forKey: key.identifier),
            case let decoder = JSONDecoder(dateDecodingStrategy: .iso8601),
            let value = try? decoder.decode([Value].self, from: loadedData)
            else { return nil }
        return value.first
    }
    
    func deleteValue<Value>(for key: Key) -> Value? where Value: Codable {
        threadTimePrint("Cache: deleting...")
        let valueInCache: Value? = loadValue(for: key) ?? nil
        setValue(nil, forKey: key.identifier)
        return valueInCache
    }
    
    func hasValue(for key: Key) -> Bool {
        threadTimePrint("Cache: hasValue...")
        simulateCacheDelay()
        return value(forKey: key.identifier) != nil
    }
}

extension AsyncCache {
    
    func asyncSave<Value>(value: Value, for key: Key, done: @escaping Done<Void>) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Void>
            do {
                try self.save(value: value, for: key)
                result = .success(void)
            } catch {
                result = .error(MyError.cacheSaving)
            }
            DispatchQueue.main.async {
                done(result)
            }
        }
    }
    
    func asyncLoadValue<Value>(for key: Key, done: @escaping Done<Value>) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Value>
            if let loaded: Value = self.loadValue(for: key) {
                result = .success(loaded)
            } else {
                result = .error(MyError.cacheEmpty)
            }
            DispatchQueue.main.async {
                done(result)
            }
        }
    }
    func asyncDeleteValue<Value>(for key: Key, done: @escaping Done<Value?>) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Value?>
            let deletedValue: Value? = self.deleteValue(for: key)
            result = .success(deletedValue)
            DispatchQueue.main.async {
                done(result)
            }
        }
    }
    
    
    func asyncHasValue(for key: Key, done: @escaping Done<Bool>) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Bool>
            let hasValue = self.hasValue(for: key)
            result = .success(hasValue)
            DispatchQueue.main.async {
                done(result)
            }
        }
    }
}

protocol Persisting {
    var cache: AsyncCache { get }
}

struct KeyCreator: Key {
    let identifier: String
    init?<T>(type: T.Type) {
        guard let keyConvertible = type as? StaticKeyConvertible.Type else { print("WARNING: returning nil :("); return nil }
        identifier = keyConvertible.key.identifier
    }
}

extension Persisting {
    func asyncLoad<C>() -> Observable<C> where C: Codable {
        guard let key = KeyCreator(type: C.self) else { return .error(MyError.cacheNoKey) }
        return Observable.create { observer in
            self.cache.asyncLoadValue(for: key) { (result: Result<C>) in
                defer { observer.onCompleted() }
                switch result {
                case .success(let loadedFromCache):
                    observer.onNext(loadedFromCache)
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
            }.do(onNext: { print("Found in cache: `\($0)`") })
    }
    
    func asyncSave<C>(_ fromBackend: C) -> Observable<C> where C: Codable {
        guard let key = KeyCreator(type: C.self) else { return .error(MyError.cacheNoKey) }
        return Observable.create { observer in
            self.cache.asyncSave(value: fromBackend, for: key) { savingResult in
                defer { observer.onCompleted() }
                switch savingResult {
                case .success:
                    print("successfully async saved `\(fromBackend)` to cache")
                    observer.onNext(fromBackend)
                case .error(let error):
                    print("Failed to async save model to cache: `\(fromBackend)`, error - `\(error)`")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func asyncDeleteValue<C>(forType type: C.Type) -> Observable<C?> where C: Codable {
        guard let key = KeyCreator(type: type) else { return .error(MyError.cacheNoKey) }
        return Observable.create { observer in
            self.cache.asyncDeleteValue(for: key) { (result: Result<C?>) in
                defer { observer.onCompleted() }
                switch result {
                case .error(let error): observer.onError(error)
                case .success(let deletedValue): observer.onNext(deletedValue)
                }
                
            }
            return Disposables.create()
        }
        .do(onNext: { print("Deleted `\($0)` for key: `\(key.identifier)` from cache") })
    }
}

private extension Cache {
    func assertBackgroundThread() {
        guard !Thread.isMainThread else { fatalError("Run on main thread") }
    }
    
    func simulateCacheDelay() {
        assertBackgroundThread()
        delay(.cache)
    }
}

