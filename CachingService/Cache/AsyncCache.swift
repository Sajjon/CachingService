//
//  AsyncCache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol AsyncCache: Cache {
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable
    func asyncDelete(for key: Key, done: Done<Void>?)
    func asyncDeleteAll(done: Done<Void>?)
    
    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable
    func asyncHasValue<Value>(ofType type: Value.Type, for key: Key, done: Done<Bool>?) where Value: Codable
}

extension AsyncCache {
    func asyncSaveOrDelete<Value>(optional: Value?, for key: Key?, done: Done<Void>?) where Value: Codable {
        let key = key ?? KeyCreator<Value>.key
        log.debug("Type: `\(Value.self)`, key: `\(key)`")
        if let value = optional {
            asyncSave(value: value, for: key, done: done)
        } else {
            asyncDelete(for: key, done: done)
        }
    }
}

extension AsyncCache {
    
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: CacheResult<Void>
            do {
                try self.save(value: value, for: key)
                result = .success(void)
            } catch {
                result = .error(ServiceError.cache(.generic))
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
                done?(CacheResult.success(void))
            }
        }
    }
    
    func asyncDeleteAll(done: Done<Void>?) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.deleteAll()
            DispatchQueue.main.async {
                done?(CacheResult.success(void))
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
    
    func asyncHasValue<Value>(ofType type: Value.Type, for key: Key, done: Done<Bool>?) where Value: Codable {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: CacheResult<Bool>
            let hasValue = self.hasValue(ofType: type, for: key)
            result = .success(hasValue)
            DispatchQueue.main.async {
                done?(result)
            }
        }
    }
}

enum CacheResult<C> {
    case success(C)
    case error(ServiceError)
}

typealias Done<C> = (CacheResult<C>) -> Void
var void: () { () }

import Cache
extension Storage: AsyncCache {
    
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable {
        async.setObject(value, forKey: key.identifier, completion: asyncResult(done))
    }
    
    func asyncDeleteAll(done: Done<Void>?) {
        async.removeAll(completion: asyncResult(done))
    }
    
    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable {
        async.object(ofType: Value.self, forKey: key.identifier, completion: asyncResult(done))
    }
    
    func asyncHasValue<Value>(ofType type: Value.Type, for key: Key, done: Done<Bool>?) where Value: Codable {
        async.existsObject(ofType: type, forKey: key.identifier, completion: asyncResult(done))
    }
}

private func asyncResult<C>(_ done: Done<C>?) -> (Result<C>) -> Void {
    guard let done = done else { return { _ in } }
    return { result in DispatchQueue.main.async { done(result.map()) } }
}

private func asyncResult<C>(_ done: Done<C?>?) -> (Result<C>) -> Void {
    guard let done = done else { return { _ in } }
    return { (result: Result<C>) in
        let cacheResult: CacheResult<C?>
        switch result {
        case .value(let loaded): cacheResult = .success(loaded); log.debug("Found data in cache")
        case .error(let genericError):
            if let storageError = genericError as? StorageError {
                switch storageError {
                case .notFound: cacheResult = .success(nil)
                default:
                    cacheResult = .error(.cache(.generic))
                    log.error("StorageError: `\(storageError)`")
                }
            } else if (genericError as NSError).code == NSFileReadNoSuchFileError {
                cacheResult = .success(nil)
                log.debug("Cache nil")
            } else {
                log.error("GENERIC ERROR: `\(genericError)`")
                cacheResult = .error(.cache(.generic))
            }
        }
        DispatchQueue.main.async { done(cacheResult) }
        
    }
}

private extension Result {
    func map() -> CacheResult<T> {
        switch self {
        case .value(let value): return CacheResult.success(value)
        case .error(let error): return CacheResult.error(.cache(error.cacheError))
        }
    }
}


extension ServiceError.CacheError {
    init?(error: Error) {
        guard let storageError = error as? StorageError else { return nil }
        switch storageError {
        case .decodingFailed: self = .decodingFailed
        case .encodingFailed: self = .encodingFailed
        case .notFound: self = .notFound
        case .typeNotMatch: self = .typeNotMatch
        case .deallocated: self = .deallocated
        default: self = .generic
        }
    }
}

extension Error {
    var cacheError: ServiceError.CacheError {
        return ServiceError.CacheError(error: self) ?? .generic
    }
}
