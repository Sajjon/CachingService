//
//  Router.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire

public typealias APIParameters = [String: Any]

public protocol Router: URLRequestConvertible {
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
    var keyPath: String? { get }
    var parameters: APIParameters? { get }
}

extension URL: Router {
    public var path: String { return absoluteString }
    public func asURLRequest() throws -> URLRequest {
        return URLRequest(url: self)
    }
}

extension String: Router {
    public var path: String { return self }
}

public extension Router {
    var method: HTTPMethod { return .get }
    var encoding: ParameterEncoding { return JSONEncoding.default }
    var keyPath: String? { return nil }
    var parameters: APIParameters? { return nil }
}

public extension Router {
    func asURLRequest() throws -> URLRequest {
        guard let url = URL(string: path) else { throw ServiceError.api(.badUrl) }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let parameters = self.parameters {
            urlRequest = try encoding.encode(urlRequest, with: parameters)
        }
        return urlRequest
    }
}

