//
//  SingleRxSignalTests.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-10-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import XCTest
@testable import SingleRxSignal
import RxSwift
import RxTest
import RxBlocking

extension MockedEvent {
    func assertEquals(_ event: Value?) {
        XCTAssertEqual(value, event)
    }
}

extension BaseExpectedResult {
    func assertHTTPEquals(_ value: Value?) {
        httpEvent.assertEquals(value)
    }
    
    func assertCacheEquals(_ value: Value?) {
        cacheEvent.assertEquals(value)
    }
    
//    func assert(_ elements: [Value]) {
//        assertCacheEquals(elements[0])
//        assertHTTPEquals(elements[1])
//    }
}

extension MockedPersistingIntegerService {
    func assertElements(_ permissions: RequestPermissions = .default) -> [Int] {
        do {
            return try getInteger(options: permissions).toBlocking().toArray()
        } catch {
            XCTFail("Failed with error: `\(error)`")
            return []
        }
    }
}

final class SingleRxSignalTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testTestHelperFunctions() {
        var cacheValue: Int? = nil
        var httpValue: Int? = nil
        var expected = ExpectedIntegerResult(cached: cacheValue, http: httpValue)
        expected.assertCacheEquals(cacheValue)
        expected.assertHTTPEquals(httpValue)
        
        cacheValue = 1
        httpValue = nil
        expected = ExpectedIntegerResult(cached: cacheValue, http: httpValue)
        expected.assertCacheEquals(cacheValue)
        expected.assertHTTPEquals(httpValue)
        
        cacheValue = nil
        httpValue = 2
        expected = ExpectedIntegerResult(cached: cacheValue, http: httpValue)
        expected.assertCacheEquals(cacheValue)
        expected.assertHTTPEquals(httpValue)
        
        
        cacheValue = nil
        httpValue = 3
        expected = ExpectedIntegerResult(cached: cacheValue, http: httpValue)
        expected.assertCacheEquals(cacheValue)
        expected.assertHTTPEquals(httpValue)
        
        cacheValue = 4
        httpValue = 5
        expected = ExpectedIntegerResult(cached: cacheValue, http: httpValue)
        expected.assertCacheEquals(cacheValue)
        expected.assertHTTPEquals(httpValue)
    }
    
    let empty: Int? = nil
    let initialCache: Int = 42
    let initialHttp: Int = 237
    
    func testDefaultRequestPermissionsCacheEmpty() {
        let expected = ExpectedIntegerResult(cached: empty, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.cachedEvent.value, empty)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, initialHttp)

        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 1)
        expected.assertHTTPEquals(elements[0])
    }

    func testDefaultRequestPermissionsSameValueInCache() {
        let same = initialCache
        let expected = ExpectedIntegerResult(same: same)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.cachedEvent.value, same)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, same)
        
        
        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
    }

    func testDefaultRequestPermissionsDifferentValuesInCache() {
        let expected = ExpectedIntegerResult(cached: initialCache, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.cachedEvent.value, initialCache)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, initialHttp)
        
        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
    }

    func testDefaultRequestPermissionsSameValueInCacheTwice() {
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: initialCache, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.cachedEvent.value, initialCache)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, next)
        
        var elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
        
        elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0], next)
    }

    func testDefaultRequestPermissionsCacheIsNilTwice() {
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: empty, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        var elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 1)
        expected.assertHTTPEquals(elements[0])
        
        elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0], next)
        XCTAssertEqual(elements[1], next)
    }

    func testDefaultRequestPermissionsSameValueInCacheTrice() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: .default, count: 3)
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: initialCache, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        var elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
        
        elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0], next)
        XCTAssertEqual(elements[1], next)
    }
//
//    func testPermissions_not_allowed_to_save_DifferentValuesInCacheAndHTTPTwice() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: RequestPermissions(cache: [.load]), count: 2)
//    }
//
//    func testPermissions_cache_saves_not_load_DifferentValuesInCacheAndHTTPTwice() {
//        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: RequestPermissions(cache: [.save]), count: 2)
//    }
//
//    func testPermissions_no_caching_DifferentValuesInCacheAndHTTPTwice() {
//        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: RequestPermissions(cache: []), count: 2)
//    }
//
//    func testDefaultPermissionsNilHttpValueDifferentValuesInCacheAndHTTP() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: nil, permissions: .default)
//    }
//
//    func testDefaultPermissionsNilHttpValueDifferentValuesInCacheAndHTTPTwice() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: nil, permissions: .default, count: 2)
//    }
//
//    func testDefaultPermissionsBothNil() {
//        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: nil, permissions: .default)
//    }
//
//    func testDefaultPermissionsValueInCacheThrowHTTPError() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPError: MyError.httpError, permissions: .default)
//    }
//
//    func testPermissions_prevent_emit_error_ValueInCacheThrowHTTPError() {
//        helperIntegerService(mockedCacheValue: 237, mockedHTTPError: MyError.httpError, permissions: RequestPermissions(backend: [.load, .emitNextEvents]))
//    }
//
//    func testDefaultPermissionsCacheEmptyThrowHTTPError() {
//        helperIntegerService(mockedCacheValue: nil, mockedHTTPError: MyError.httpError, permissions: .default)
//    }
//
//    func testPermissions_prevent_emit_error_CacheEmptyThrowHTTPError() {
//        helperIntegerService(mockedCacheValue: nil, mockedHTTPError: MyError.httpError, permissions: RequestPermissions(backend: [.load, .emitNextEvents]))
//    }
//
//    func testCacheFails() {
//        helperIntegerService(errorCaching: MyError.cacheSaving, mockedHTTPValue: 42, permissions: RequestPermissions(cache: [.load, .save]))
//    }
}
