//
//  Alamofire+Codable.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//


import Foundation
import Alamofire

enum AlamofireDecodableError: Error {
    case invalidKeyPath
    case emptyKeyPath
}

extension AlamofireDecodableError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .invalidKeyPath:   return "Nested object doesn't exist by this keyPath."
        case .emptyKeyPath:     return "KeyPath can not be empty."
        }
    }
}

extension DataRequest {
    
    private static func DecodableObjectSerializer<T: Decodable>(_ keyPath: String?, _ decoder: JSONDecoder) -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            if let error = error {
                return .failure(error)
            }
            if let keyPath = keyPath {
                if keyPath.isEmpty {
                    return .failure(AlamofireDecodableError.emptyKeyPath)
                }
                return DataRequest.decodeToObject(byKeyPath: keyPath, decoder: decoder, response: response, data: data)
            }
            return DataRequest.decodeToObject(decoder: decoder, response: response, data: data)
        }
    }
    
    private static func decodeToObject<T: Decodable>(decoder: JSONDecoder, response: HTTPURLResponse?, data: Data?) -> Result<T> {
        let result = Request.serializeResponseData(response: response, data: data, error: nil)
        
        switch result {
        case .success(let data):
            do {
                let object = try decoder.decode(T.self, from: data)
                return .success(object)
            } catch {
                return .failure(error)
            }
        case .failure(let error): return .failure(error)
        }
    }
    
    private static func decodeToObject<T: Decodable>(byKeyPath keyPath: String, decoder: JSONDecoder, response: HTTPURLResponse?, data: Data?) -> Result<T> {
        let result = Request.serializeResponseJSON(options: [], response: response, data: data, error: nil)
        
        switch result {
        case .success(let json):
            if let nestedJson = (json as AnyObject).value(forKeyPath: keyPath) {
                do {
                    let data = try JSONSerialization.data(withJSONObject: nestedJson)
                    let object = try decoder.decode(T.self, from: data)
                    return .success(object)
                } catch {
                    return .failure(error)
                }
            } else {
                return .failure(AlamofireDecodableError.invalidKeyPath)
            }
        case .failure(let error): return .failure(error)
        }
    }
    
    /// Adds a handler to be called once the request has finished.
    
    /// - parameter queue:             The queue on which the completion handler is dispatched.
    /// - parameter keyPath:           The keyPath where object decoding should be performed. Default: `nil`.
    /// - parameter decoder:           The decoder that performs the decoding of JSON into semantic `Decodable` type. Default: `JSONDecoder()`.
    /// - parameter completionHandler: The code to be executed once the request has finished and the data has been mapped by `JSONDecoder`.
    
    /// - returns: The request.
    
    @discardableResult
    func responseDecodableObject<T: Decodable>(queue: DispatchQueue? = nil, keyPath: String? = nil, decoder: JSONDecoder = JSONDecoder(), completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        decoder.dateDecodingStrategy = .iso8601
        return response(queue: queue, responseSerializer: DataRequest.DecodableObjectSerializer(keyPath, decoder), completionHandler: completionHandler)
    }
}

