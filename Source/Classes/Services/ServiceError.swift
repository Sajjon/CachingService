//
//  MyError.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire

public enum ServiceError: Error {
    
    case unknown
    
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
        
        case httpGeneric
        
        indirect case noError(NoError)
        public enum NoError: Error {
            case cancelled
        }
        
        indirect case network(NetworkError)
        public enum NetworkError: Error {
            case noNetwork
            case badUrl(Router?)
            case multipartEncodingFailed(underlyingError: Error?)
            case parameterEncodingFailed(underlyingError: Error?)
            case responseSerializationFailed(underlyingError: Error?)
            case responseValidationFailed(ResponseValidationFailureReason)
            
            public enum ResponseValidationFailureReason {
                case dataFileNil
                case dataFileReadFailed(at: URL)
                case missingContentType(acceptableContentTypes: [String])
                case unacceptableContentType(acceptableContentTypes: [String], responseContentType: String)
                case unacceptableStatusCode(code: Int)
            }
        }
        
        indirect case json(JSONError)
        public enum JSONError: Error {
            case encoding(EncodingError?)
            case decoding(DecodingError?)
        }
        
    }
}

extension ServiceError.APIError {
    init?(error: Error?) {
        guard let genericError = error else { return nil }
        if let decodingError = genericError as? DecodingError {
            self = .json(.decoding(decodingError))
        } else if let encodingError = genericError as? EncodingError {
            self = .json(.encoding(encodingError))
        } else if let alamofireError = error as? AFError {
            switch alamofireError {
            case .invalidURL(let url):
                self = .network(.badUrl(url as? Router))
            case .multipartEncodingFailed:
                self = .network(.multipartEncodingFailed(underlyingError: alamofireError.underlyingError))
            case .parameterEncodingFailed:
                self = .network(.parameterEncodingFailed(underlyingError: alamofireError.underlyingError))
            case .responseSerializationFailed:
                self = .network(.responseSerializationFailed(underlyingError: alamofireError.underlyingError))
            case .responseValidationFailed(let reason):
                switch reason {
                case .dataFileNil: self = .network(.responseValidationFailed(.dataFileNil))
                case .dataFileReadFailed(let url): self = .network(.responseValidationFailed(.dataFileReadFailed(at: url)))
                case .missingContentType(let acceptable): self = .network(.responseValidationFailed(.missingContentType(acceptableContentTypes: acceptable)))
                case .unacceptableContentType(let acceptable, let response): self = .network(.responseValidationFailed(.unacceptableContentType(acceptableContentTypes: acceptable, responseContentType: response)))
                case .unacceptableStatusCode(let statusCode): self = .network(.responseValidationFailed(.unacceptableStatusCode(code: statusCode)))
                }
            }
        } else {
            let nsError = genericError as NSError
            let urlErrorCode = URLError.Code(rawValue: nsError.code)
            
            switch urlErrorCode {
            case .notConnectedToInternet: self = .network(.noNetwork)
            case .cancelled: self = .noError(.cancelled)
            default: return nil
            }
        }
    }
}

public extension ServiceError {
    var unauthorized: Bool {
        switch self {
        case .api(.network(let network)): return network.unauthorized
        default: return false
        }
    }
    
    var httpStatusCode: HTTPStatusCode? {
        switch self {
       case .api(.network(let network)): return network.httpStatusCode
        default:
            return nil
        }
    }
}


public extension ServiceError.APIError.NetworkError {
    var unauthorized: Bool {
        guard let code = httpStatusCode else { return false }
        return code == .unauthorized
    }
    
    var httpStatusCode: HTTPStatusCode? {
        switch self {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let statusCode): return HTTPStatusCode(rawValue: statusCode)
            default: return nil
            }
        default:
            return nil
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
