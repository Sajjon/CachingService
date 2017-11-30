//
//  CachingServiceTests.swift
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


final class CachingServiceTests: BaseTestCase {
    
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
    
    func testDefaultRequestPermissionsCacheEmpty() {
        let expected = ExpectedIntegerResult(cached: empty, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.cachedEvent.value, empty)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, initialHttp)
        
        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 1)
        expected.assertHTTPEquals(elements[0])
    }
   
    func testThatCachingServicesDoesNotErrorWhenLoadingNilValueFromCacheAndThatItSavesHTTPValueInCacheByDefault() {
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
    
    func testThatCachingServicesLoadsValueFromCacheAndSavesHTTPValueInCacheByDefault() {
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: initialCache, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        var elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
        
        let nextNext: Int = 1337
        integerService.mockedIntegerHTTPClient.mockedEvent = MockedEvent(nextNext)
        elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0], next)
        XCTAssertEqual(elements[1], nextNext)
        
        elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements[0], nextNext)
        XCTAssertEqual(elements[1], nextNext)
    }
    
    func testThatCachingServiceDoesNotSaveToCacheWhenToldNotToButItEmitsValuesFromBackendByDefault() {
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: initialCache, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        let source: ServiceSource = .cacheAndBackendOptions(SourceOptions(shouldCache: false))
        var elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 2)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
        
        let nextNext: Int = 1337
        expected.httpEvent = MockedEvent(nextNext)
        integerService.mockedIntegerHTTPClient.mockedEvent = expected.httpEvent
        elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(expected.cacheEvent.value, initialCache)
        XCTAssertEqual(expected.httpEvent.value, nextNext)
    }
    
    func testThatCachingServiceDoesNotSaveToCacheAndThatItDoesNoEmitAnyValueFromBackendWhenToldNotTo() {
        let expected = ExpectedIntegerResult(cached: initialCache, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        let source: ServiceSource = .cacheAndBackendOptions(SourceOptions(emitValue: false, shouldCache: false))
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedValue, initialHttp)
        var elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialCache)
        
        let newHttp: Int = 1337
        expected.httpEvent = MockedEvent(newHttp)
        integerService.mockedIntegerHTTPClient.mockedEvent = expected.httpEvent
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedValue, newHttp)
        elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialCache)
    }
    
    func testThatCachingServicesSavesToCacheByDefaultWhenOnlyFetchingFromBackend() {
        let next = initialHttp
        let expected = ExpectedIntegerResult(cached: empty, http: next)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        
        let source: ServiceSource = .backend
        var elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], next)
        expected.assertHTTPEquals(next)
        
        let nextNext: Int = 1337
        expected.httpEvent = MockedEvent(nextNext)
        integerService.mockedIntegerHTTPClient.mockedEvent = expected.httpEvent
        elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], nextNext)
        expected.assertHTTPEquals(nextNext)
    }
    
    func testThatCachingServicesDeletesValueWhenBackendReturnsEmptyResponse() {
        let expected = ExpectedIntegerResult(cached: initialCache, http: empty)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.mockedValue, initialCache)
        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 1)
        expected.assertCacheEquals(elements[0])
        XCTAssertEqual(integerService.mockedIntegerCache.mockedValue, empty)
    }
    
    func testThatCachingServiviesDoesNotDeleteCachedValueWhenBackendReturnsError() {
        let expected = ExpectedIntegerResult(cached: initialCache, httpError: .httpError)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerCache.mockedValue, initialCache)
        let (elements, _) = integerService.materialized()
        XCTAssertEqual(integerService.mockedIntegerCache.mockedValue, initialCache)
        XCTAssertEqual(integerService.mockedIntegerCache.mockedValue, elements[0])
        
    }
    
    func testThatCachingServiceEmitsBackendErrorByDefault() {
        let expectedError: MyError = .httpError
        let expected = ExpectedIntegerResult(cached: dontCare, httpError: expectedError)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.error, expectedError)
        let (_, errorFromService) = integerService.materialized(.default)
        XCTAssertEqual(errorFromService, expectedError)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.error, errorFromService)
    }
   
    func testThatCachingServiceCatchesBackendErrorIfToldTo() {
        let mockedHttpError: MyError = .httpError
        let expected = ExpectedIntegerResult(cached: dontCare, httpError: mockedHttpError)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.error, mockedHttpError)
        let (elements, errorFromService) = integerService.materialized(.cacheAndBackendOptions(SourceOptions(emitError: false)))
        XCTAssertEqual(errorFromService, nil)
        XCTAssertEqual(elements.count, 0)
    }
    
    func testThatCachingServiceDoesNotEmitAnyEventWhenOnlyFetchingFromBackendIfToldTo() {
        let expected = ExpectedIntegerResult(cached: dontCare, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        let elements = integerService.assertElements(.backendOptions(SourceOptions(emitValue: false)))
        XCTAssertEqual(elements.count, 0)
    }
    
    func testThatCachingServiceDoesNotEmitAnyEventWhenFetchingFromEmptyCacheAndFromBackendIfToldTo() {
        let expected = ExpectedIntegerResult(cached: nil, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        let elements = integerService.assertElements(.cacheAndBackendOptions(SourceOptions(emitValue: false)))
        XCTAssertEqual(elements.count, 0)
    }
    
    func testThatCachingServicOnlyEmitsSingleEventWhenFetchingFromCacheWithValueAndFromBackendIfToldTo() {
        let expected = ExpectedIntegerResult(cached: initialCache, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        let elements = integerService.assertElements(.cacheAndBackendOptions(SourceOptions(emitValue: false)))
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialCache)
    }
    
    func testThatCachingServiceDoesNotEmitEventFromBackendIfToldToButThatItEmitsLoadedCacheValuesAndThatItSavesToCacheByDefaultWhenFetchingFromCacheAndBackend() {
        let expected = ExpectedIntegerResult(cached: initialCache, http: initialHttp)
        let integerService = MockedPersistingIntegerService(mocked: expected)
        let source: ServiceSource = .cacheAndBackendOptions(SourceOptions(emitValue: false))
        var elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialCache)
        elements = integerService.assertElements(source)
        XCTAssertEqual(elements.count, 1)
        XCTAssertEqual(elements[0], initialHttp)
    }
}
