//
//  StaticKeyConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol StaticKeyConvertible {
    static var key: Key { get }
}
