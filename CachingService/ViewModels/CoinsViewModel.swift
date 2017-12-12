//
//  CoinsViewModel.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModel {}

//let cacheKeyName = "name"
final class CoinsViewModel: ViewModel {
    
    private let coinService: CoinServiceProtocol
    private let activityIndicator = ActivityIndicator()
    
    lazy var isFetching: Observable<Bool> = activityIndicator.asObservable()
    
    private let getFromCacheAndBackendButtonTapped: Observable<Void>
    private let getFromCacheOnlyButtonTapped: Observable<Void>
    private let clearCacheButtonTapped: Observable<Void>
    private let clearModelsButtonTapped: Observable<Void>
    
    lazy var models = Observable<[Coin]>.merge(cacheAndBackend, cacheOnly, clearCache, clearModels)
    
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
    
    init(
        coinService: CoinServiceProtocol,
        getFromCacheAndBackendButton: Observable<Void>,
        getFromCacheOnlyButton: Observable<Void>,
        clearCacheButton: Observable<Void>,
        clearModelsButton: Observable<Void>
        ) {
        self.coinService = coinService
        self.getFromCacheAndBackendButtonTapped = getFromCacheAndBackendButton
        self.getFromCacheOnlyButtonTapped = getFromCacheOnlyButton
        self.clearCacheButtonTapped = clearCacheButton
        self.clearModelsButtonTapped = clearModelsButton
    }
}
