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
        assertBackgroundThread()
        log.info("Cache: saving...")
        let data = try JSONEncoder().encode([value])
        set(data, forKey: key.identifier)
    }
    
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        assertBackgroundThread()
        log.info("Cache: loading...")
        guard
            let loadedData = data(forKey: key.identifier),
            case let decoder = JSONDecoder(dateDecodingStrategy: .iso8601),
            let value = try? decoder.decode([Value].self, from: loadedData)
            else { return nil }
        return value.first
    }
    
    func deleteValue(for key: Key) {
        assertBackgroundThread()
        log.verbose("Cache: deleting...")
        setValue(nil, forKey: key.identifier)
    }
    
    func hasValue(for key: Key) -> Bool {
        assertBackgroundThread()
        log.verbose("Cache: hasValue...")
        return value(forKey: key.identifier) != nil
    }
}

private func assertBackgroundThread() {
    if Thread.isMainThread { log.error("RUNNING ON MAIN THREAD") }
}


