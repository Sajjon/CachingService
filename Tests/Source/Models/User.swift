//
//  User.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
struct User: Codable {
    let userId: Int
    var firstName: String
    var lastName: String
}

extension User {
    var name: String { return "\(firstName) \(lastName)" }
}

extension User: Equatable {
    public static func ==(rhs: User, lhs: User) -> Bool {
        return rhs.userId == lhs.userId && rhs.name == lhs.name
    }
}

////MARK: - StaticKeyConvertible
//extension User: StaticKeyConvertible {
//    static var key: Key { return "user" }
//}

//MARK: - Filterable
extension User: Filterable {
    static var primaryKeyPath: AnyKeyPath? { return \User.userId }
    static var keyPaths: [AnyKeyPath] { return stringPaths.map { $0 } + intPaths.map { $0 } }
}

extension User {
    static var stringPaths: [KeyPath<User, String>] {
        return [\.firstName, \.lastName, \.name]
    }
    
    static var intPaths: [KeyPath<User, Int>] {
        return [\.userId]
    }
}
