//
//  Codable_Extension.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    convenience init(dateDecodingStrategy strategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        dateDecodingStrategy = strategy
    }
}

public extension JSONEncoder {
    convenience init(dateEncodingStrategy strategy: JSONEncoder.DateEncodingStrategy) {
        self.init()
        dateEncodingStrategy = strategy
    }
}

