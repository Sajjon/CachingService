//
//  CoinsResponse.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-11.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct CoinsResponse: Codable {
    let coinsMap: [String: Coin]
    var coins: [Coin] { return coinsMap.map { $1 } }
    enum CodingKeys: String, CodingKey {
        case coinsMap = "Data"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coinsMap = try values.decode([String: Coin].self, forKey: .coinsMap)
    }
}

extension CoinsResponse {
    func toList() -> CoinList {
        return CoinList(coins)
    }
}
