//
//  CoinService.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
//
//struct Adaptor<Response: Decodable, To: Codable>: Codable {
//    var response: Response
//    var to: To
//    init(from decoder: Decoder) throws {
//        
//    }
//}

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

protocol CoinServiceProtocol: Service, Persisting {
    func getCoins(fromSource source: ServiceSource) -> Observable<[Coin]>
    func getCachedCoins(using filter: FilterConvertible) -> Observable<[Coin]>
}

final class CoinService: CoinServiceProtocol {
    typealias Router = CoinRouter
    
    let reachability: ReachabilityService
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(
        reachability: ReachabilityService,
        httpClient: HTTPClientProtocol,
        cache: AsyncCache) {
        self.reachability = reachability
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getCoins(fromSource source: ServiceSource = .default) -> Observable<[Coin]> {
        log.info("GETTING COINS")
        let coinsResponse: Observable<CoinsResponse> = get(request: CoinRouter.all, from: source)
        return coinsResponse.map { $0.coins }
    }
    
    func getCachedCoins(using filter: FilterConvertible) -> Observable<[Coin]> {
        return getModels(using: filter)
    }
}
