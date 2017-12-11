//
//  MyError.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public enum ServiceError: Error {
    
    indirect case cache(CacheError)
    public enum CacheError: Error {
        case empty
        case noKey
        case saving
    }
    
    indirect case api(APIError)
    public enum APIError: Error {
        case noNetwork
        case httpGeneric
        case badUrl
    }
}

extension ServiceError: Equatable {
    public static func ==(lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.cache(let lhsCache), .cache(let rhsCache)): return lhsCache == rhsCache
        case (.api(let lhsApi), .api(let rhsApi)): return lhsApi == rhsApi
        default: return false
        }
    }
}

extension ServiceError.CacheError: Equatable {
    public static func ==(lhs: ServiceError.CacheError, rhs: ServiceError.CacheError) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty): return true
        case (.noKey, .noKey): return true
        case (.saving, .saving): return true
        default: return false
        }
    }
}

extension ServiceError.APIError: Equatable {
    public static func ==(lhs: ServiceError.APIError, rhs: ServiceError.APIError) -> Bool {
        switch (lhs, rhs) {
        case (.noNetwork, .noNetwork): return true
        case (.httpGeneric, .httpGeneric): return true
        case (.badUrl, .badUrl): return true
        default: return false
        }
    }
}

public func ==(lhsGeneral: ServiceError, rhs: ServiceError.APIError) -> Bool {
    guard case let .api(lhs) = lhsGeneral else { return false }
    return lhs == rhs
}

public func ==(lhs: ServiceError.APIError, rhsGeneral: ServiceError) -> Bool {
    return rhsGeneral == lhs
}

public func ==(lhsGeneric: Error, rhs: ServiceError) -> Bool {
    guard let lhs = lhsGeneric as? ServiceError else { return false }
    return lhs == rhs
}

public func ==(lhs: ServiceError, rhsGeneric: Error) -> Bool {
    guard let rhs = rhsGeneric as? ServiceError else { return false }
    return lhs == rhs
}
