//
//  AsyncCache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public enum CacheResult<C> {
    case success(C)
    case error(ServiceError)
}

public typealias Done<C> = (CacheResult<C>) -> Void
var void: () { () }

public protocol AsyncCache: Cache {
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable
    func asyncDelete(for key: Key, done: Done<Void>?)
    func asyncDeleteAll(done: Done<Void>?)
    
    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable
    func asyncHasValue<Value>(ofType type: Value.Type, for key: Key, done: Done<Bool>?) where Value: Codable
}

public extension AsyncCache {
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



extension Error {
    var cacheError: ServiceError.CacheError {
        return ServiceError.CacheError(error: self) ?? .generic
    }
}
