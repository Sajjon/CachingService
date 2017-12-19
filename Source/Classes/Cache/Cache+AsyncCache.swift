//
//  Cache+AsyncCache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-19.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public extension AsyncCache {
    
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
