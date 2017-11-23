//
//  ObserverOptions.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct ObservableOptions {
    let emitValue: Bool
    let emitError: Bool
    let shouldCache: Bool
    init(emitValue: Bool = true, emitError: Bool = true, shouldCache: Bool = true) {
        self.emitValue = emitValue
        self.emitError = emitError
        self.shouldCache = shouldCache
    }
}

enum FetchFrom {
    case cacheAndBackendOptions(ObservableOptions)
    case cache
    case backendOptions(ObservableOptions)
}

extension FetchFrom {
    static var backend: FetchFrom { return .backendOptions(ObservableOptions()) }
    static var cacheAndBackend: FetchFrom { return .cacheAndBackendOptions(ObservableOptions()) }
    static var `default`: FetchFrom = .cacheAndBackend
}

extension FetchFrom {
    var shouldFetchFromBackend: Bool {
        switch self {
        case .cache: return false
        default: return true
        }
    }
    
    var shouldSaveToCache: Bool {
        switch self {
        case .cache: return false // undefined
        case .cacheAndBackendOptions(let options): return options.shouldCache
        case .backendOptions(let options): return options.shouldCache
        }
    }
    
    var catchErrorsFromBackend: Bool {
        switch self {
        case .cache: return false // undefined
        case .cacheAndBackendOptions(let options): return !options.emitError
        case .backendOptions(let options): return !options.emitError
        }
    }
    
    var shouldLoadFromCache: Bool {
        switch self {
        case .backendOptions: return false
        default: return true
        }
    }
    
    var emitEventForValueFromBackend: Bool {
        switch self {
        case .cache: return true // undefined
        case .cacheAndBackendOptions(let options): return options.emitValue
        case .backendOptions(let options): return options.emitValue
        }
    }
}
