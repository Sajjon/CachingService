//
//  BaseTest.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SingleRxSignal
import RxSwift
import RxTest
import RxBlocking

class BaseTest: XCTestCase {
    
    func helperIntegerService(mockedCacheValue c: Int?, mockedHTTPValue h: Int?, permissions: RequestPermissions, count: Int = 1) {
        _helperIntegerService(mockedCacheValue: c, mockedHTTPEvent: MockedEvent<Int>.value(h), permissions: permissions, count: count)
    }
    
    func helperIntegerService(mockedCacheValue c: Int?, mockedHTTPError e: MyError, permissions: RequestPermissions, count: Int = 1) {
        _helperIntegerService(mockedCacheValue: c, mockedHTTPEvent: MockedEvent<Int>.error(e), permissions: permissions, count: count)
    }
}

private extension BaseTest {
    private func _helperIntegerService(mockedCacheValue c: Int?, mockedHTTPEvent h: MockedEvent<Int>, permissions: RequestPermissions, count: Int) {
        helperGet(
            permissions: permissions,
            integerService: MockedPersistingIntegerService(
                httpClient: MockedIntegerHTTPClient(mockedEvent: h),
                cache: MockedCacheForInteger(cachedInteger: c)
            ),
            count: count
        )
    }
    
    private func helperGet(permissions: RequestPermissions, integerService: MockedPersistingIntegerService, count: Int) {
        var expected = ExpectedIntegerResult(
            cacheValue: integerService.mockedIntegerCache.cached,
            httpEvent: integerService.mockedIntegerHTTPClient.mockedEvent
        )
        
        func validate() {
            let result = integerService.getInteger(options: permissions)
                .toBlocking()
                .materialize()
            
            switch result {
            case .failed(_, let errorFromSignal):
                switch expected.httpEvent {
                case .error(let expectedError):
                    guard let castedError = errorFromSignal as? MyError else { XCTFail("failed to cast error"); return }
                   print("comparing errors")
                    XCTAssertEqual(castedError, expectedError)
                case .value(let expectedValue):
                    XCTFail("Expected value: `\(expectedValue)`, but received error: `\(errorFromSignal)`")
                }
            case .completed(let elements):
                switch elements.count {
                case 0: XCTAssertTrue(true, "Trivial case, no elements")
                case 1:
                    let value = elements[0]
                    XCTAssertNotNil(value)
                    if let cached = expected.cacheValue {
                        XCTAssertEqual(value, cached)
                    } else {
                        guard case let .value(expectedHttpValue) = expected.httpEvent else { XCTFail("expected value"); return }
                        XCTAssertEqual(value, expectedHttpValue)
                    }
                case 2:
                    guard case let .value(expectedHttpValue) = expected.httpEvent else { XCTFail("expected value"); return }
                    XCTAssertNotNil(expected.cacheValue)
                    XCTAssertNotNil(expectedHttpValue)
                    let cached = expected.cacheValue!
                    XCTAssertEqual(elements[0], cached)
                    XCTAssertEqual(elements[1], expectedHttpValue)
                default: XCTFail("Got too many events?")
                }
            }
            
            expected = ExpectedIntegerResult(lastRun: expected, permissions: permissions)
            XCTAssertEqual(integerService.mockedIntegerCache.cached, expected.cacheValue)
        }
        count.timesCounting {
            if count > 1 { print("### Running test, loop: `\($0 + 1)` of `\(count)` ###\n\n") }
            validate()
        }
        
    }
}
