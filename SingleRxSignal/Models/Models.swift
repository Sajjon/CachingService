//
//  Models.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol StaticKeyConvertible {
    static var key: Key { get }
}

protocol NameOwner: Codable, CustomStringConvertible, StaticKeyConvertible {
    var name: String { get set }
    init(name: String)
}

extension NameOwner {
    var description: String { return name }
}

struct User: NameOwner {
    var name: String
    static var key: Key { return "user" }
}

struct Group: NameOwner {
    var name: String
    static var key: Key { return "group" }
}

