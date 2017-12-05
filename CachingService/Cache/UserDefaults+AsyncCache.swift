//
//  UserDefaults+AsyncCache.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension UserDefaults: AsyncCache {}
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

private extension AsyncCache {
    func assertBackgroundThread() {
        guard !Thread.isMainThread else { fatalError("Run on main thread") }
    }
    
    func simulateCacheDelay() {
        assertBackgroundThread()
        delay(.cache)
    }
}

