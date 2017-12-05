//
//  HTTPContentType.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-10-31.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation

public enum CommonHTTPHeaderKey: String {
    case contentLength = "Content-Length"
    case contentType = "Content-Type"
    case authorization = "Authorization"
    case accept = "Accept"
}

public enum HTTPContentType: String {
    case applicationJSON = "application/json"
    case multipartFormData = "multipart/form-data"
}


extension HTTPContentType: CustomStringConvertible {}
public extension HTTPContentType {
    var description: String {
        return self.rawValue
    }
}
