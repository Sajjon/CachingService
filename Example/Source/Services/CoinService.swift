//
//  CoinService.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import CachingService



public final class CoinList: OrderedListOfUniquePersistables {
    public var elements: [Coin]
    public init(_ coins: [Coin] = []) {
        self.elements = coins
    }

}


protocol CoinServiceProtocol: Service, Persisting {
    func getCoins(fromSource source: ServiceSource) -> Observable<[Coin]>
    func getCoinPrice(for coin: Coin, fromSource source: ServiceSource) -> Observable<Coin>
    func getCachedCoins(using filter: FilterConvertible?) -> Observable<[Coin]>
}

final class CoinService: CoinServiceProtocol {
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(httpClient: HTTPClientProtocol, cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getCoins(fromSource source: ServiceSource = .default) -> Observable<[Coin]> {
//        return get(modelType: CoinsResponse.self, request: CoinRouter.all, from: source, key: nil).map { $0.coins }
        return getList(request: CoinRouter.all, type: CoinList.self) { (modelFromBackend: CoinsResponse) -> CoinList in
            return modelFromBackend.toList()
        }
    }

    func getCoinPrice(for coin: Coin, fromSource source: ServiceSource = .default) -> Observable<Coin> {

//        return getCoinPrice(for: coin, fromSource: source).flatMapLatest { (price: Observable<Price>) -> Observable<Coin> in
//            self.getCachedCoins().flatMapLatest {
//                self.cache.save(value: <#T##Decodable & Encodable#>, for: <#T##Key#>)
//            }
//        }

    }
    
    func getCachedCoins(using filter: FilterConvertible? = nil) -> Observable<[Coin]> {
        let allCachedCoins = getCoins(fromSource: .cache)
        guard let filter = filter else { return allCachedCoins }
        return allCachedCoins.filterValues(using: filter)
    }
}

private extension CoinService {

    func getCoinPrice(for coin: Coin) -> Observable<Price> {
        
    }
}

