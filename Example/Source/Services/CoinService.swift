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

protocol CoinServiceProtocol: Service, Persisting {
    func getCoins(fromSource source: ServiceSource) -> Observable<[Coin]>
    func getCachedCoins(using filter: FilterConvertible) -> Observable<[Coin]>
}

final class CoinService: CoinServiceProtocol {
    typealias Router = CoinRouter
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(
        httpClient: HTTPClientProtocol,
        cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getCoins(fromSource source: ServiceSource = .default) -> Observable<[Coin]> {
        return get(modelType: CoinsResponse.self, request: CoinRouter.all, from: source, key: nil).map { $0.coins }
    }
    
    func getCachedCoins(using filter: FilterConvertible) -> Observable<[Coin]> {
        return getCoins(fromSource: .cache).filterValues(using: filter)
    }
}

final class ImageService: ImageServiceProtocol {
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(
        httpClient: HTTPClientProtocol,
        cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
}
