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
    func deleteValue(for key: Key)
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
    func asyncDeleteValue(for key: Key, done: @escaping Done<Void>)
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
        threadTimePrint("Saving to cache...")
        simulateCacheDelay()
        let data = try JSONEncoder().encode([value])
        set(data, forKey: key.identifier)
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        threadTimePrint("Loading from cache...")
        simulateCacheDelay()
        guard
            let loadedData = data(forKey: key.identifier),
            case let decoder = JSONDecoder(dateDecodingStrategy: .iso8601),
            let value = try? decoder.decode([Value].self, from: loadedData)
            else { return nil }
        return value.first
    }
    
    func deleteValue(for key: Key) {
        threadTimePrint("Deleting from cache...")
        simulateCacheDelay()
        setValue(nil, forKey: key.identifier)
    }
    
    func hasValue(for key: Key) -> Bool {
        threadTimePrint("Checking cache...")
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
    func asyncDeleteValue(for key: Key, done: @escaping Done<Void>) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Void>
            self.deleteValue(for: key)
            result = .success(void)
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
}


func threadTimePrint(_ message: String) {
    let threadString = Thread.isMainThread ? "MAIN THREAD" : "BACKGROUND THREAD"
    print("\(threadString) - \(Date.timeAsString): \(message)")
}


enum SimulatedDelay {
    case cache
    case http
}

extension SimulatedDelay {
    var time: TimeInterval {
        switch self {
        case .cache: return 2
        case .http: return 5
        }
    }
}

func delay(_ simulatedDelay: SimulatedDelay) {
    let sleepTime: UInt32 = UInt32(simulatedDelay.time)
    sleep(sleepTime)
}

let cacheKeyName = "name"

private extension Cache {
    func assertBackgroundThread() {
        guard !Thread.isMainThread else { fatalError("Run on main thread") }
    }
    
    func simulateCacheDelay() {
        assertBackgroundThread()
        delay(.cache)
    }
}


public extension JSONDecoder {
    convenience init(dateDecodingStrategy strategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        dateDecodingStrategy = strategy
    }
}

public extension JSONEncoder {
    convenience init(dateEncodingStrategy strategy: JSONEncoder.DateEncodingStrategy) {
        self.init()
        dateEncodingStrategy = strategy
    }
}

