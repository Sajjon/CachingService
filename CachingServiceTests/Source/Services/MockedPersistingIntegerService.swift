//
//  MockedPersistingIntegerService.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
import RxSwift

final class MockedPersistingIntegerService {
    let mockedIntegerCache: MockedCacheForInteger
    let mockedIntegerHTTPClient: MockedIntegerHTTPClient
    
    init(httpClient: MockedIntegerHTTPClient, cache: MockedCacheForInteger) {
        self.mockedIntegerHTTPClient = httpClient
        self.mockedIntegerCache = cache
    }
}

extension MockedPersistingIntegerService: IntegerServiceProtocol {
    var httpClient: HTTPClientProtocol { return mockedIntegerHTTPClient }
    
    func getInteger(fromSource source: ServiceSource) -> Observable<Int> {
        return get(request: TestRouter.integer, from: source)
    }
}

extension MockedPersistingIntegerService: Persisting {
    var cache: AsyncCache { return mockedIntegerCache }
}

extension MockedPersistingIntegerService {
    convenience init(mocked: ExpectedIntegerResult) {
        self.init(
            httpClient: MockedIntegerHTTPClient(mockedEvent: mocked.httpEvent),
            cache: MockedCacheForInteger(mockedEvent: mocked.cacheEvent)
        )
    }
}
