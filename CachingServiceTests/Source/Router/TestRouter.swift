//
//  TestRouter.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import Alamofire

enum TestRouter {
    case integer
}

extension TestRouter: Router {}

extension TestRouter {
    var path: String {
        switch self {
        case .integer: return "integer"
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

