//
//  EnumInformationExpressible.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public protocol EnumInformationExpressible {
    static var all: [Self] { get }
}
