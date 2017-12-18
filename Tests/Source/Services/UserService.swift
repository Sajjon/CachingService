//
//  UserService.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//
import Foundation
@testable import CachingService
import RxSwift

protocol UserServiceProtocol: Service, Persisting {
    func getUser(fromSource source: ServiceSource) -> Observable<User>
    func getCachedUsers(using filter: FilterConvertible) -> Observable<[User]>
}

final class UserService: UserServiceProtocol {
    typealias Router = UserRouter
    
    let reachability: ReachabilityServiceConvertible
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(
        reachability: ReachabilityServiceConvertible,
        httpClient: HTTPClientProtocol,
        cache: AsyncCache) {
        self.reachability = reachability
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getUser(fromSource source: ServiceSource = .default) -> Observable<User> {
        log.info("GETTING USER")
        return get(request: Router.user, from: source)
    }
    
    func getCachedUsers(using filter: FilterConvertible) -> Observable<[User]> {
        return getModels(using: filter)
    }
}

