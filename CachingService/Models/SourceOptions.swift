//
//  SourceOptions.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct SourceOptions {
    let emitValue: Bool
    let emitError: Bool
    let shouldCache: Bool
    init(emitValue: Bool = true, emitError: Bool = true, shouldCache: Bool = true) {
        self.emitValue = emitValue
        self.emitError = emitError
        self.shouldCache = shouldCache
    }
}

extension SourceOptions {
    static var `default`: SourceOptions { return SourceOptions() }
}
