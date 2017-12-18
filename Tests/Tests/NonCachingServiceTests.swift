//
//  NonCachingServiceTests.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import CachingService
import RxSwift
import RxTest
import RxBlocking

class BaseTestCase: XCTestCase {
    let dontCare: Int? = nil
    let empty: Int? = nil
    let initialCache: Int = 42
    let initialHttp: Int = 237
}

final class NonCachingServiceTests: BaseTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
    }
    
    func testThatNonCachingServicesDoesNotErrorWhenTryToLoadingNilValueFromNonExistingCacheAndThatItDoesNotErrorWhenTryingToSavesHTTPValueToNonExistingCache() {
        let next = initialHttp
        let expected = MockedEvent(next)
        let integerService = MockedNonPersistingIntegerService(mocked: expected)
        var elements = integerService.assertElements(.cacheAndBackend)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialHttp)
    }
}
