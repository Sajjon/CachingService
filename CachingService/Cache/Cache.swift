//
//  Cache.swift
//  CachingService
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
