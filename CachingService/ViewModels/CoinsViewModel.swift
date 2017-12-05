//
//  CoinsViewModel.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

//let cacheKeyName = "name"
final class CoinsViewModel: ViewModel {
    
    private let bag = DisposeBag()
    private let coinService: CoinServiceProtocol
    private let activityIndicator = ActivityIndicator()
    
    lazy var isFetching: Observable<Bool> = activityIndicator.asObservable()
    
    private let getButtonTapped: Observable<Void>
    private let clearButtonTapped: Observable<Void>
    
    lazy var coinResponse: Observable<[Coin]> = self.getButtonTapped.flatMapLatest({ _ in
        self.coinService.getCoins(fromSource: .default).trackActivity(self.activityIndicator)
    })
    
    init(
        coinService: CoinServiceProtocol,
        getButton: Observable<Void>,
        clearButton: Observable<Void>
        ) {
        self.coinService = coinService
        self.getButtonTapped = getButton
        self.clearButtonTapped = clearButton
        
        clearButtonTapped.flatMapLatest { _ in
            self.coinService.asyncDeleteValue(forType: Coin.self)
        }
        .subscribe(onError: { print("Error deleting from cache: \($0)") }, onCompleted: { print("Finished deleting from cache") }).disposed(by: bag)
    }
}
