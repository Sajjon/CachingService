//
//  URL+Key.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-23.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

extension URL: Key {}
public extension URL {
    var identifier: String { return absoluteString }
}
