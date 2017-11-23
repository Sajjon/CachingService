//
//  UserService.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

protocol UserServiceProtocol: Service, Persisting {
    func getUser(fetchFrom: FetchFrom) -> Observable<User>
}

final class UserService: UserServiceProtocol {
    typealias Router = UserRouter
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(httpClient: HTTPClientProtocol, cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getUser(fetchFrom: FetchFrom = .default) -> Observable<User> {
        log.info("GETTING USER")
        return get(router: Router.user, fetchFrom: fetchFrom)
    }
}
