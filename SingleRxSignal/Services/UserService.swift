//
//  UserService.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyBeaver

protocol UserServiceProtocol: Service, Persisting {
    func getUser(fetchFrom: FetchFrom) -> Observable<User>
}

final class UserService: UserServiceProtocol {
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(httpClient: HTTPClientProtocol, cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getUser(fetchFrom: FetchFrom = .default) -> Observable<User> {
        log.info("GETTING USER")
        return get(fetchFrom: fetchFrom)
    }
}
