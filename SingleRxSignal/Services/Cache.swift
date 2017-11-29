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
    func deleteValue(for key: Key)

    func loadValue<Value>(for key: Key) -> Value? where Value: Codable
    func hasValue(for key: Key) -> Bool
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

protocol AsyncCache: Cache {
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable
    func asyncDelete(for key: Key, done: Done<Void>?)

    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable
    func asyncHasValue(for key: Key, done: Done<Bool>?)
}

extension AsyncCache {
    func asyncSaveOrDelete<Value>(optional: Value?, for key: Key, done: Done<Void>?) where Value: Codable {
        if let value = optional {
            asyncSave(value: value, for: key, done: done)
        } else {
            asyncDelete(for: key, done: done)
        }
    }
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
    
    func deleteValue(for key: Key) {
        threadTimePrint("Cache: deleting...")
        setValue(nil, forKey: key.identifier)
    }
    
    func hasValue(for key: Key) -> Bool {
        threadTimePrint("Cache: hasValue...")
        simulateCacheDelay()
        return value(forKey: key.identifier) != nil
    }
}

extension AsyncCache {
    
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Void>
            do {
                try self.save(value: value, for: key)
                result = .success(void)
            } catch {
                result = .error(MyError.cacheSaving)
            }
            DispatchQueue.main.async {
                done?(result)
            }
        }
    }
    
    func asyncDelete(for key: Key, done: Done<Void>?) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.deleteValue(for: key)
            DispatchQueue.main.async {
                done?(Result.success(void))
            }
        }
    }

    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let loaded: Value? = self.loadValue(for: key)
            DispatchQueue.main.async {
                done?(.success(loaded))
            }
        }
    }
    
    func asyncHasValue(for key: Key, done: Done<Bool>?) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Bool>
            let hasValue = self.hasValue(for: key)
            result = .success(hasValue)
            DispatchQueue.main.async {
                done?(result)
            }
        }
    }
}

enum Result<C> {
    case success(C)
    case error(MyError)
}

typealias Done<C> = (Result<C>) -> Void
var void: () { () }

extension Persisting {
    func asyncLoad<C>(for key: Key) -> Observable<C?> where C: Codable {
        return Observable.create { observer in
            self.cache.asyncLoadValue(for: key) { (result: Result<C?>) in
                switch result {
                case .success(let loadedFromCache):
                    observer.onNext(loadedFromCache)
                    observer.onCompleted()
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
        .do(onNext: { guard let cached = $0 else { log.verbose("Cache empty"); return }; log.verbose("Found in cache: `\(cached)`") })
    }
    
    func asyncSaveOrDelete<C>(_ optional: C?, key: Key) -> Observable<C?> where C: Codable {
        return Observable.create { observer in
            self.cache.asyncSaveOrDelete(optional: optional, for: key) { savingResult in
                defer { observer.onCompleted() }
                switch savingResult {
                case .success:
                    if let value = optional {
                        log.verbose("Did cache: `\(value)`")
                    } else {
                        log.verbose("Wrote nil to cache")
                    }
                    observer.onNext(optional)
                case .error(let error):
                    log.error("Failed to cache error - `\(error)`")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    func asyncDeleteValue<C>(forType type: C.Type) -> Observable<C?> where C: Codable {
        let optional: C? = nil
        return asyncSaveOrDelete(optional, key: KeyCreator<C>.key)
    }
}


protocol OptionalType {
    static var wrappedType: Any.Type { get }
}
extension Optional: OptionalType {
    static var wrappedType: Any.Type { return Wrapped.self }
}

struct FourLevelTypeUnwrapper<T> {
    static var fourLevelUnwrappedType: Any.Type {
        guard let optionalTypeLevel1 = T.self as? OptionalType.Type else { return T.self }
        guard let optionalTypeLevel2 = optionalTypeLevel1.wrappedType as? OptionalType.Type else { return optionalTypeLevel1.wrappedType }
        guard let optionalTypeLevel3 = optionalTypeLevel2.wrappedType as? OptionalType.Type else { return optionalTypeLevel2.wrappedType }
        guard let optionalTypeLevel4 = optionalTypeLevel3.wrappedType as? OptionalType.Type else { return optionalTypeLevel3.wrappedType }
        return optionalTypeLevel4.wrappedType
    }
}
struct KeyCreator<T> {
    static var key: Key {
        return "\(FourLevelTypeUnwrapper<T>.fourLevelUnwrappedType)"
    }
}

extension Persisting {
    func asyncLoad<C>() -> Observable<C?> where C: Codable {
        return asyncLoad(for: KeyCreator<C>.key)
    }
    
    func asyncSave<C>(_ optional: C?) -> Observable<C?> where C: Codable {
        return asyncSaveOrDelete(optional, key: KeyCreator<C>.key)
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

