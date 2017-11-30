//
//  CachingServiceFilterTests.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation


import XCTest
@testable import SingleRxSignal
import RxSwift
import RxTest
import RxBlocking

extension UserServiceProtocol {
    func assertElements(_ source: ServiceSource = .default) -> [User] {
        return materialized(source).elements
    }
    
    func materialized(_ source: ServiceSource = .default) -> (elements: [User], error: MyError?) {
        return materialized(fromSource: source)
    }
}


final class CachingServiceFilterTests: XCTestCase {
    
    let dontCare: List<User>? = nil
    let empty: List<User>? = nil
    let userFooBar = User(userId: 0, firstName: "Foo", lastName: "Bar")
    let userBarBaz = User(userId: 1, firstName: "Bar", lastName: "Baz")
    let userBazBuz = User(userId: 2, firstName: "Baz", lastName: "Buz")
    let userBuzFoo = User(userId: 3, firstName: "Buz", lastName: "Foo")
    let userFooBaz = User(userId: 4, firstName: "Foo", lastName: "Baz")
    let userFooBuz = User(userId: 5, firstName: "Foo", lastName: "Buz")
    var initialCache: List<User> { return List([userFooBar, userBarBaz]) }
    var initialHttp: List<User> { return  List([userBazBuz, userBuzFoo, userFooBaz, userFooBuz]) }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testPersistingServiceFilterReturnsEmptyArrayForJibberishQueryButNonEmptyForProperQuery() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        var filterResult = userService.assertElements(Filter(query: "qwerty"))
        XCTAssertEqual(filterResult.count, 0)
        filterResult = userService.assertElements(Filter(query: "bar"))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 2)
        filterResult = userService.assertElements(Filter(query: "b"))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 2)
    }
    
    func testPersistingServiceFilterReturnsSingleEmptyArrayWhenToldTo() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        var filterResult = userService.assertElements(Filter(query: "qwerty")) // default: removeEmptyArrays: true
        XCTAssertEqual(filterResult.count, 0)
        filterResult = userService.assertElements(Filter(query: "qwerty"), removeEmptyArrays: false)
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertTrue(filterResult[0].isEmpty)
    }
    
    func testPersistingServiceFilterReturnsEmptyArrayForNonMatchingCase() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        let queryString = "bar"
        var filterResult = userService.assertElements(Filter(query: queryString))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 2)
        filterResult = userService.assertElements(Filter(query: queryString, caseSensitive: true))
        XCTAssertEqual(filterResult.count, 0)
    }
    
    func testPersistingServiceFilterAndCaching() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        var filterResult = userService.assertElements(Filter(query: "foo"))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 1)
        let elements = userService.assertElements(.cacheAndBackend)
        expected.assertCacheEquals(elements[0])
        expected.assertHTTPEquals(elements[1])
        filterResult = userService.assertElements(Filter(query: "foo"))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 3)
    }
    
    func testPersistingServiceFilterUsingIdentifiers() {
        let allUsers = List(initialCache.elements + initialHttp.elements)
        let expected = ExpectedUserResult(cached: allUsers, http: dontCare)
        let userService = MockedPersistingUserService(mocked: expected)
        var filterResults = userService.assertElements(Filter(query: "foo"))
        let observableFilter: Observable<[User]> = userService.getModels(using: Filter(query: "foo"))
        let filtered = userService.getCachedUsers(using: Filter(query: "foo"))
        XCTAssertEqual(filterResults.count, 1)
        XCTAssertEqual(filterResults[0].count, 4)
        filterResults = userService.assertElements(Filter(query: "foo", caseSensitive: true), removeEmptyArrays: true)
        XCTAssertEqual(filterResults.count, 0)
        filterResults = userService.assertElements(Filter(identifiers: [0, 3, 4, 5]))
        XCTAssertEqual(filterResults.count, 1)
        XCTAssertEqual(filterResults[0].count, 4)
        filterResults = userService.assertElements(Filter(identifiers: [0, 3, 4, 5], .or, query: "buz"))
        XCTAssertEqual(filterResults.count, 1)
        XCTAssertEqual(filterResults[0].count, 5)
        filterResults = userService.assertElements(Filter(identifiers: [0, 3, 4, 5], .and, query: "buz"))
        XCTAssertEqual(filterResults.count, 1)
        XCTAssertEqual(filterResults[0].count, 2)
    }
}
