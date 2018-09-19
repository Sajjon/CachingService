//
//  CoinRouter.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire
import CachingService

enum CoinRouter {
    case all
    case price(for: Coin)
}

extension CoinRouter: Router {}

extension CoinRouter {
    var path: String {
        switch self {
        case .all: return "all/coinlist"
        case .price(let coin): return "price?fsym=\(coin.coinId)&tsyms=BTC,USD"
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
    
//    var keyPath: String? {
//        switch self {
//        case .all: return "Data"
//        }
//    }
}


