//
//  ReachabilityAndRetryTests.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-12-06.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

import XCTest
@testable import CachingService
import RxSwift
import RxTest
import RxBlocking


final class ReachabilityAndRetryTests: BaseTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
    }
    
    func testReachabilityNotifies() {
        let reachability = MockedReachabilityService(reachabilityStatus: .unreachable)
        do {
            var elements = try reachability.reachability.asObservable().toBlocking().toArray()
            XCTAssertEqual(elements.count, 1)
            XCTAssertTrue(elements[0] == .unreachable)
            reachability.reachabilityStatus = .reachable(viaWiFi: true)
            elements = try reachability.reachability.asObservable().toBlocking().toArray()
            XCTAssertEqual(elements.count, 1)
            XCTAssertTrue(elements[0] == .reachable(viaWiFi: true))
        } catch {
            XCTFail("Failed due to error: `\(error)`")
        }
    }
    
    func testThatReachabilityReturnsValuesFromHTTPWhenReachable() {
        let expected = ExpectedIntegerResult(cached: dontCare, http: initialHttp)
        let expectedReachability: ReachabilityStatus = .reachable(viaWiFi: true)
        let reachability = MockedReachabilityService(reachabilityStatus: expectedReachability)
        
        let httpClient = MockedIntegerHTTPClient(
            mockedEvent: expected.httpEvent,
            reachability: reachability
        )
        
        let integerService = MockedPersistingIntegerService(httpClient: httpClient, cache: MockedCacheForInteger(mockedEvent: expected.cacheEvent))
        
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, initialHttp)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedReachability.reachabilityStatus, expectedReachability)
        
        let elements = integerService.assertElements()
        XCTAssertEqual(elements.count, 1)
        expected.assertHTTPEquals(elements[0])
    }
    
    func testThatReachabilityReturnsNoValuesFromHTTPWhenUnreachable() {
        let expected = ExpectedIntegerResult(cached: dontCare, http: initialHttp)
        let expectedReachability: ReachabilityStatus = .unreachable
        let reachability = MockedReachabilityService(reachabilityStatus: expectedReachability)
        
        let httpClient = MockedIntegerHTTPClient(
            mockedEvent: expected.httpEvent,
            reachability: reachability
        )
        
        let integerService = MockedPersistingIntegerService(httpClient: httpClient, cache: MockedCacheForInteger(mockedEvent: expected.cacheEvent))
        
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedEvent.value, initialHttp)
        XCTAssertEqual(integerService.mockedIntegerHTTPClient.mockedReachability.reachabilityStatus, expectedReachability)
        
        
        let (elements, error) = integerService.materialized()
        XCTAssertEqual(elements.count, 0)
        XCTAssertNotNil(error)
        XCTAssertTrue(error! == ServiceError.APIError.noNetwork)
    }
    
    func testThatReachabilityRetriesWhenNoNetworkIfToldTo() {
        let expected = ExpectedIntegerResult(cached: dontCare, httpError: ServiceError.api(.noNetwork))
        let expectedReachability: ReachabilityStatus = .unreachable
        let reachability = MockedReachabilityService(reachabilityStatus: expectedReachability)
        
        let httpClient = MockedIntegerHTTPClient(
            mockedEvent: expected.httpEvent,
            reachability: reachability
        )
        
        let integerService = MockedPersistingIntegerService(httpClient: httpClient, cache: MockedCacheForInteger(mockedEvent: expected.cacheEvent))
        
        let source = ServiceSource.cacheAndBackendOptions(ServiceOptionsInfo.foreverRetrying)
        XCTAssertNotNil(source.retryWhenReachable)
        XCTAssertTrue(source.retryWhenReachable!.sameIgnoringAssociatedValue(.forever))
        let (elements, error) = integerService.materialized(source)
        XCTAssertEqual(elements.count, 0)
        XCTAssertNil(error)
//        XCTAssertTrue(error! == ServiceError.APIError.noNetwork)
    }
    
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func testThatReachabilityRetriesWhenNoNetworkIfToldToBadUrl() {
        let expected = ExpectedIntegerResult(cached: dontCare, http: initialHttp)
        let expectedReachability: ReachabilityStatus = .unreachable
        let reachability = MockedReachabilityService(reachabilityStatus: expectedReachability)
        
        let httpClient = MockedIntegerHTTPClient(
            mockedEvent: expected.httpEvent,
            reachability: reachability
        )
        
        let integerService = MockedPersistingIntegerService(httpClient: httpClient, cache: MockedCacheForInteger(mockedEvent: expected.cacheEvent))
        
        let source = ServiceSource.cacheAndBackendOptions(ServiceOptionsInfo.default.inserting(.retryWhenReachable(ServiceRetry.count(1000))))
        XCTAssertNotNil(source.retryWhenReachable)
//        XCTAssertTrue(source.retryWhenReachable!.sameIgnoringAssociatedValue(.forever))
        
        let (elements, _) = integerService.materialized(source)
        XCTAssertEqual(elements.count, 0)
//        XCTAssertNotNil(error)
//        XCTAssertTrue(error! == ServiceError.APIError.noNetwork)
        
        let shortDelay: Double = 1
        let timeout: Double = 2
        
        XCTAssertTrue(shortDelay < timeout)
        
//        delay(shortDelay) {
            log.warning("Changing reacability to reachable")
//        }

        
        let expectations = expectation(description: "Reachability should become reachable")
        let bag = DisposeBag()
        reachability.reachabilityStatus = .reachable(viaWiFi: true)
        let observable: Observable<Int> = integerService.getInteger(fromSource: source)
        observable.subscribe(onNext: {
            log.warning("got event `\($0)`")
            expectations.fulfill()
        }, onError: { log.warning("error: `\($0)`") }, onCompleted: { log.warning("onCompleted") }, onDisposed: { log.warning("disposed") }).disposed(by: bag)
        

    
        waitForExpectations(timeout: timeout, handler: nil)
        
        
        let (elements2, _) = integerService.materialized(source)
        XCTAssertEqual(elements2.count, 2)
        XCTAssertEqual(elements2[0], initialHttp)
        XCTAssertEqual(elements2[1], initialHttp)
    }
}
