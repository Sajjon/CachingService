//
//  ObserverOptions.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

enum ServiceSource {
    case cacheAndBackendOptions(SourceOptions)
    case cache
    case backendOptions(SourceOptions)
}

extension ServiceSource {
    static var backend: ServiceSource { return .backendOptions(.default) }
    static var cacheAndBackend: ServiceSource { return .cacheAndBackendOptions(.default) }
    static var `default`: ServiceSource = .cacheAndBackend
}

extension ServiceSource {
    var shouldServiceSourceBackend: Bool {
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
