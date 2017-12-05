//
//  HTTPHeaderStoreProtocol.swift
//  API
//
//  Created by Alexander Cyon on 2017-11-01.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation
import Alamofire

public protocol HTTPHeaderStoreProtocol: class {
    
    var headers: [String: String] { set get }
    
    func addHeader(_ value: String, for key: String)
    func removeHeader(for key: String)
    func header(for key: String) -> String?
    
    func injectHeaders(to request: inout URLRequest)
}


public extension HTTPHeaderStoreProtocol {
    
    func injectHeaders(to request: inout URLRequest) {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func addHeader(_ value: String, for key: String) {
        headers[key] = value
    }
    
    func removeHeader(for key: String) {
        headers.removeValue(forKey: key)
    }
}

public extension HTTPHeaderStoreProtocol {

    func header(for key: String) -> String? {
        return headers[key]
    }
}

public final class HTTPHeaderStore: HTTPHeaderStoreProtocol {
    public var headers = [String: String]()
    public init(headers: [String: String] = [:]) {
        self.headers = headers
    }
}

