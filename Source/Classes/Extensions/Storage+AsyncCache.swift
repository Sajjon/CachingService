//
//  Storage+AsyncCache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-19.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Cache

extension Storage: AsyncCache {}
public extension Storage {
    
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
        case .value(let loaded): cacheResult = .success(loaded)
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
