//
//  Observable+String.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-14.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

extension Observable where Element == String? {
    public var nilIfEmpty: Observable<String?> {
        return self.map { $0.nilIfEmpty }
    }
}
