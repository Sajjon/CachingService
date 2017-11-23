//
//  MockedNonPersistingIntegerService.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import RxSwift

final class MockedNonPersistingIntegerService {
    
    let mockedIntegerHTTPClient: MockedIntegerHTTPClient
    
    init(httpClient: MockedIntegerHTTPClient) {
        self.mockedIntegerHTTPClient = httpClient
    }
}

extension MockedNonPersistingIntegerService: IntegerServiceProtocol {
    var httpClient: HTTPClientProtocol { return mockedIntegerHTTPClient }
    
    func getInteger(fetchFrom: FetchFrom) -> Observable<Int> {
        return get(router: TestRouter.integer, fetchFrom: fetchFrom)
    }
}

extension MockedNonPersistingIntegerService {
    convenience init(mocked: MockedEvent<Int>) {
        self.init(
            httpClient: MockedIntegerHTTPClient(mockedEvent: mocked)
        )
    }
}
