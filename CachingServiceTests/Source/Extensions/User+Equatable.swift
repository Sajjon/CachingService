//
//  User+Equatable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-29.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//


import Foundation
@testable import SingleRxSignal

extension User: Equatable {
    public static func ==(rhs: User, lhs: User) -> Bool {
        return rhs.userId == lhs.userId && rhs.name == lhs.name
    }
}
