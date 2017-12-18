//
//  DataConvertible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-18.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol DataConvertible {
    init?(data: Data)
}

extension UIImage: DataConvertible {}
