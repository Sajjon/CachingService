//
//  User.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct User: Codable {
    let userId: Int
    var firstName: String
    var lastName: String
}

extension User {
    var name: String { return "\(firstName) \(lastName)" }
}

//MARK: - StaticKeyConvertible
extension User: StaticKeyConvertible {
    static var key: Key { return "user" }
}

//MARK: - Filterable
extension User: Filterable {
    static var primaryKeyPath: AnyKeyPath? { return \User.userId }
    static var keyPaths: [AnyKeyPath] { return stringPaths.map { $0 } + intPaths.map { $0 } }
}


extension User {
    var _primaryKeyPath: PartialKeyPath<User> { return \.name }
    var primaryKeyPath: KeyPath<User, String> { return \.name }
    var keyPaths: [KeyPath<User, String>] { return [primaryKeyPath] }
}

extension User {
    static var stringPaths: [KeyPath<User, String>] {
        return [\.firstName, \.lastName, \.name]
    }
    
    static var intPaths: [KeyPath<User, Int>] {
        return [\.userId]
    }
}
