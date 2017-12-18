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
        /// Unable to retrieve specific caching error
        case generic
        /// Unable to automatically create key for type
        case noKey
        /// Object can not be found
        case notFound
        /// Object is found, but casting to requested type failed
        case typeNotMatch
        /// Can't perform Decode
        case decodingFailed
        /// Can't perform Encode
        case encodingFailed
        /// The storage has been deallocated
        case deallocated
    }
    
    indirect case api(APIError)
    public enum APIError: Error {
        case noNetwork
        case cancelled
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
        case (.generic, .generic): return true
        case (.noKey, .noKey): return true
        case (.notFound, .notFound): return true
        case (.typeNotMatch, .typeNotMatch): return true
        case (.decodingFailed, .decodingFailed): return true
        case (.encodingFailed, .encodingFailed): return true
        case (.deallocated, .deallocated): return true
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
        case (.cancelled, .cancelled): return true
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


extension ServiceError.APIError {
    init?(error: Error?) {
        guard
            let genericError = error,
            case let nsError = genericError as NSError,
            case let urlErrorCode = URLError.Code(rawValue: nsError.code)
            else { return nil }
        switch urlErrorCode {
        case .notConnectedToInternet: self = .noNetwork
        case .cancelled: self = .cancelled
        default: return nil
        }
    }
}

extension Error {
    var apiError: ServiceError.APIError {
        return ServiceError.APIError(error: self) ?? .httpGeneric
    }
}

extension Optional where Wrapped == Error {
    var apiError: ServiceError.APIError {
        switch self {
        case .some(let wrapped): return wrapped.apiError
        case .none: return .httpGeneric
        }
    }
}
