//
//  AsyncCache.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

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

