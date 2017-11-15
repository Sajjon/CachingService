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

final class SingleRxSignalTests: BaseTest {
    
    var bag: DisposeBag!
    
    override func setUp() {
        bag = DisposeBag()
    }
    
    func testDefaultRequestPermissionsCacheEmpty() {
        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: .default)
    }
    
    func testDefaultRequestPermissionsSameValueInCache() {
        let same: Int = 42
        helperIntegerService(mockedCacheValue: same, mockedHTTPValue: same, permissions: .default)
    }
    
    func testDefaultRequestPermissionsDifferentValuesInCache() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: .default)
    }
    
    func testDefaultRequestPermissionsSameValueInCacheTwice() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: .default, count: 2)
    }
    
    func testDefaultRequestPermissionsCacheIsNilTwice() {
        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: .default, count: 2)
    }
    
    func testDefaultRequestPermissionsSameValueInCacheTrice() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: .default, count: 3)
    }
    
    func testPermissions_not_allowed_to_save_DifferentValuesInCacheAndHTTPTwice() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: 42, permissions: RequestPermissions(cache: [.load]), count: 2)
    }
    
    func testPermissions_cache_saves_not_load_DifferentValuesInCacheAndHTTPTwice() {
        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: RequestPermissions(cache: [.save]), count: 2)
    }
    
    func testPermissions_no_caching_DifferentValuesInCacheAndHTTPTwice() {
        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: 42, permissions: RequestPermissions(cache: []), count: 2)
    }
    
    func testDefaultPermissionsNilHttpValueDifferentValuesInCacheAndHTTP() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: nil, permissions: .default)
    }
    
    func testDefaultPermissionsNilHttpValueDifferentValuesInCacheAndHTTPTwice() {
        helperIntegerService(mockedCacheValue: 237, mockedHTTPValue: nil, permissions: .default, count: 2)
    }
    
    func testDefaultPermissionsBothNil() {
        helperIntegerService(mockedCacheValue: nil, mockedHTTPValue: nil, permissions: .default)
    }
    
}
