//
//  PriceRouter.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire
import CachingService

protocol SymbolConvertible: Encodable {
    var symbol: String { get }
}

struct Symbol: Codable, SymbolConvertible {
    let symbol: String
}

extension String: SymbolConvertible {
    var symbol: String { return self }
}

struct PricesRequest: Encodable {
    let from: [String]
    let to: [String]
}

struct PriceRequest: Encodable {
    let from: String
    let to: [String]
}

enum PriceRouter {
    case price(PriceRequest)
    case prices(PricesRequest)
}

extension PriceRouter: Router {}

extension PriceRouter {
    var path: String {
        switch self {
        case .prices: return "pricemulti"
        case .price: return "price"
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

