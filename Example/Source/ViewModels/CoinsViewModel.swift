//
//  CoinsViewModel.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import CachingService

protocol ViewModel {}

final class CoinsViewModel: ViewModel {
    
    private let coinService: CoinServiceProtocol
    private let activityIndicator = ActivityIndicator()
    
    lazy var isFetching: Observable<Bool> = activityIndicator.asObservable()
    
    private let getFromCacheAndBackendButtonTapped: Observable<Void>
    private let getFromCacheOnlyButtonTapped: Observable<Void>
    private let clearCacheButtonTapped: Observable<Void>
    private let clearModelsButtonTapped: Observable<Void>
    private let filterBarChanged: Observable<String?>
    
    lazy var models = Observable<[Coin]>.merge(get, clear, filtered)
    
    private lazy var get = Observable<[Coin]>.merge(cacheAndBackend, cacheOnly)
    private lazy var clear = Observable<[Coin]>.merge(clearCache, clearModels)
    
    private lazy var cacheAndBackend: Observable<[Coin]> = self.getFromCacheAndBackendButtonTapped.flatMapLatest({ _ in
        self.coinService
            .getCoins(fromSource: .cacheAndBackendOptions(ServiceOptionsInfo.foreverRetrying))
            .trackActivity(self.activityIndicator)
    })
    
    private lazy var cacheOnly: Observable<[Coin]> = self.getFromCacheOnlyButtonTapped.flatMapLatest({ _ in
        self.coinService
            .getCoins(fromSource: .cache)
            .trackActivity(self.activityIndicator)
    })
    
    private lazy var clearCache: Observable<[Coin]> = self.clearCacheButtonTapped.flatMapLatest({ _ in
        self.coinService.asyncDeleteValue(forType: CoinsResponse.self).flatMap { _ in return Observable<[Coin]>.just([]) }
            .trackActivity(self.activityIndicator)
    })
    
    private lazy var clearModels: Observable<[Coin]> = self.clearModelsButtonTapped.flatMapLatest({ _ in
        return Observable<[Coin]>.just([])
    })
    
    private lazy var filtered: Observable<[Coin]> = self.filterBarChanged.flatMap({ (maybeQuery: String?) -> Observable<[Coin]> in
        if let query = maybeQuery {
           return self.coinService.getCachedCoins(using: Filter(query: query))
        } else {
            return self.coinService
                .getCoins(fromSource: .cache)
        }
    })
    
    init(
        coinService: CoinServiceProtocol,
        getFromCacheAndBackendButton: Observable<Void>,
        getFromCacheOnlyButton: Observable<Void>,
        clearCacheButton: Observable<Void>,
        clearModelsButton: Observable<Void>,
        filterBar: Observable<String?>
        ) {
        self.coinService = coinService
        self.getFromCacheAndBackendButtonTapped = getFromCacheAndBackendButton
        self.getFromCacheOnlyButtonTapped = getFromCacheOnlyButton
        self.clearCacheButtonTapped = clearCacheButton
        self.clearModelsButtonTapped = clearModelsButton
        self.filterBarChanged = filterBar
    }
}
