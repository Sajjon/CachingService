//
//  MockedPersistingIntegerService.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import RxSwift

final class MockedPersistingIntegerService: IntegerServiceProtocol {
    let mockedIntegerCache: MockedCacheForInteger
    let mockedIntegerHTTPClient: MockedIntegerHTTPClient
    
    init(httpClient: MockedIntegerHTTPClient, cache: MockedCacheForInteger) {
        self.mockedIntegerHTTPClient = httpClient
        self.mockedIntegerCache = cache
    }
    
    func getInteger(options: RequestPermissions) -> Observable<Int> {
        return get(options: options)
    }
}

extension MockedPersistingIntegerService: Persisting {
    var cache: AsyncCache { return mockedIntegerCache }
    var httpClient: HTTPClientProtocol { return mockedIntegerHTTPClient }
}
