//
//  MockedNonPersistingIntegerService.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
import RxSwift

final class MockedNonPersistingIntegerService {
    
    let mockedIntegerHTTPClient: MockedIntegerHTTPClient
    
    init(httpClient: MockedIntegerHTTPClient) {
        self.mockedIntegerHTTPClient = httpClient
    }
}

extension MockedNonPersistingIntegerService: IntegerServiceProtocol {
    
    var httpClient: HTTPClientProtocol { return mockedIntegerHTTPClient }

    func getInteger(fromSource source: ServiceSource) -> Observable<Int> {
        return get(request: TestRouter.integer, from: source)
    }
}

extension MockedNonPersistingIntegerService {
    convenience init(mocked: MockedEvent<Int>) {
        self.init(
            httpClient: MockedIntegerHTTPClient(mockedEvent: mocked)
        )
    }
}

final class MockedReachabilityService: ReachabilityServiceConvertible {
    
    var reachabilityStatus: ReachabilityStatus
   
    init(reachabilityStatus: ReachabilityStatus = .wifi) {
        self.reachabilityStatus = reachabilityStatus
    }
    
    var status: Observable<ReachabilityStatus> {
        return Observable.just(reachabilityStatus)
    }
}
