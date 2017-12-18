//
//  UserRouter.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire
@testable import CachingService

public enum UserRouter {
    case user
}

extension UserRouter: Router {}

public extension UserRouter {
    var path: String {
        switch self {
        case .user: return "user"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: APIParameters? {
        switch self {
        default: return nil
        }
    }
}


