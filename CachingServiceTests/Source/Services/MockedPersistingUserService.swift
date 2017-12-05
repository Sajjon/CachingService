//
//  MockedPersistingUserService.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
import RxSwift

final class ExpectedUserResult: BaseExpectedResult<List<User>> {}

final class MockedPersistingUserService {
    let mockedUserHTTPClient: MockedUserHTTPClient
    let mockedUserCache: MockedCacheForUser
    
    init(httpClient: MockedUserHTTPClient, cache: MockedCacheForUser) {
        self.mockedUserHTTPClient = httpClient
        self.mockedUserCache = cache
    }
    
    func getCachedUsers(using filter: FilterConvertible) -> Observable<[User]> {
        return getModels(using: filter)
    }
}

extension MockedPersistingUserService: Service {
    var reachability: ReachabilityService {
        return try! DefaultReachabilityService()
    }
    
    var httpClient: HTTPClientProtocol { return mockedUserHTTPClient }
}

extension MockedPersistingUserService: Persisting {
    var cache: AsyncCache { return mockedUserCache }
}

extension MockedPersistingUserService {
    convenience init(mocked: ExpectedUserResult) {
        self.init(
            httpClient: MockedUserHTTPClient(mockedEvent: mocked.httpEvent),
            cache: MockedCacheForUser(mockedEvent: mocked.cacheEvent)
        )
    }
}

extension MockedPersistingUserService {
    func assertElements(_ filter: FilterConvertible, removeEmptyArrays: Bool = true) -> [List<User>] {
        return materialized(filter: filter, removeEmptyArrays: removeEmptyArrays).elements
    }
    
    func materialized(_ filter: FilterConvertible, removeEmptyArrays: Bool = true) -> (elements: [List<User>], error: ServiceError?) {
        return materialized(filter: filter)
    }
}

extension MockedPersistingUserService {
    func assertElements(_ source: ServiceSource = .default) -> [List<User>] {
        return materialized(source).elements
    }
    
    func materialized(_ source: ServiceSource = .default) -> (elements: [List<User>], error: ServiceError?) {
        return materialized(fromSource: source)
    }
}
