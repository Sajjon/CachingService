//
//  ViewModel.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModel {}

let cacheKeyName = "name"
final class UserViewModel: ViewModel {
    
    private let bag = DisposeBag()
    private let userService: UserServiceProtocol
    private let activityIndicator = ActivityIndicator()
    
    lazy var isFetching: Observable<Bool> = activityIndicator.asObservable()
    
    private let getButtonTapped: Observable<Void>
    private let clearButtonTapped: Observable<Void>
    lazy var userResponse: Observable<User> = self.getButtonTapped.flatMapLatest({ _ in
        return self.userService.getUser(fetchFrom: .default).trackActivity(self.activityIndicator)
    })
    
    init(
        userService: UserServiceProtocol,
        getButton: Observable<Void>,
        clearButton: Observable<Void>
        ) {
        self.userService = userService
        self.getButtonTapped = getButton
        self.clearButtonTapped = clearButton
        //        userResponse = getButton.flatMapLatest { _ in
        //            userService.getUser(options: .default)
        //        }.trackActivity(activityIndicator)
        //        userResponse = Observable.of(getButton, clearButton).merge().map { _ in
        //            return self.getUser()
        //        }
        clearButtonTapped.flatMapLatest { _ in
            self.userService.asyncDeleteValue(forType: User.self)
        }
        .subscribe(onError: { print("Error deleting from cache: \($0)") }, onCompleted: { print("Finished deleting from cache") }).disposed(by: bag)
    }
}
