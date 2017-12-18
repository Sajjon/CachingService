//
//  String_Extensions.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension Optional where Wrapped == String {
    var nilIfEmpty: String? {
        switch self {
        case .some(let string): return string.isEmpty ? nil : string
        case .none: return nil
        }
    }
}
