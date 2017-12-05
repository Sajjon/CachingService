//
//  Group.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct Group: Codable {
    let name: String
}

//MARK: - StaticKeyConvertible
extension Group: StaticKeyConvertible {
    static var key: Key { return "group" }
}
