//
//  ServiceSource.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public enum ServiceSource {
    case cacheAndBackendOptions(ServiceOptionsInfo)
    case cache
    case backendOptions(ServiceOptionsInfo)
}

public extension ServiceSource {
    static var backend: ServiceSource { return .backendOptions(.default) }
    static var cacheAndBackend: ServiceSource { return .cacheAndBackendOptions(.default) }
    static var `default`: ServiceSource = .cacheAndBackend
}

public extension ServiceSource {
    var shouldFetchFromBackend: Bool {
        switch self {
        case .cache: return false
        default: return true
        }
    }
    
    var ifCachedPreventDownload: Bool {
        switch self {
        case .backendOptions(let options): return options.ifCachedPreventDownload
        case .cacheAndBackendOptions(let options): return options.ifCachedPreventDownload
        default: return false
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
    
    var shouldRetryIfUnreachable: Bool {
        return retryWhenReachable != nil
    }
    
    var retryWhenReachable: ServiceRetry? {
        switch self {
        case .backendOptions(let options): return options.retryWhenReachable
        case .cacheAndBackendOptions(let options): return options.retryWhenReachable
        default: return nil
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
