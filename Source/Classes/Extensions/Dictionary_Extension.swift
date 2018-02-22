//
//  Dictionary_Extension.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

internal extension Dictionary {
    init(_ keyValueTuples: [(Key, Value)]) {
        self.init(minimumCapacity: keyValueTuples.count)
        keyValueTuples.forEach { self[$0.0] = $0.1 }
    }
    
    func flatMapValues<T>(transform: (Value) -> T?) -> [Key: T] {
        var dict = [Key: T]()
        for (key, value) in zip(keys, values.flatMap(transform)) {
            dict[key] = value
        }
        return dict
    }
}
