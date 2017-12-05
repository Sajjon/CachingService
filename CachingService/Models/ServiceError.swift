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
        
        indirect case network(Network)
        public enum Network: Error {
            case notConnected
        }
        
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
        case (.network(let lhsNetwork), .network(let rhsNetwork)): return lhsNetwork == rhsNetwork
        case (.httpGeneric, .httpGeneric): return true
        case (.badUrl, .badUrl): return true
        default: return false
        }
    }
}

extension ServiceError.APIError.Network: Equatable {
    public static func ==(lhs: ServiceError.APIError.Network, rhs: ServiceError.APIError.Network) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected): return true
        }
    }
}
