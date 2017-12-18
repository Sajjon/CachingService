//
//  URLRequest_Extension.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public extension URLRequest {
    mutating func prependUrl(prefix: String) {
        self.url = self.url?.prepending(prefix)
    }
}

public extension URL {
    func prepending(_ prefix: String) -> URL? {
        return URL(string: "\(prefix)\(absoluteString)")
    }
    
}
