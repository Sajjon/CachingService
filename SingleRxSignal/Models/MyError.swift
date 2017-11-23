//
//  MyError.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
enum MyError: Error, Equatable {
    case cacheEmpty
    case cacheNoKey
    case cacheSaving
    case httpError
    
    case test
}
