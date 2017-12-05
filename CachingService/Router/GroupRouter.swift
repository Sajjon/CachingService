//
//  GroupRouter.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire

public enum GroupRouter {
    case group
}

extension GroupRouter: Router {}

public extension GroupRouter {
    var path: String {
        switch self {
        case .group: return "group"
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


