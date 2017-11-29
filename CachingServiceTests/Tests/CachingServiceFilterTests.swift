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
    func assertElements(_ fetchFrom: FetchFrom = .default) -> [User] {
        return materialized(fetchFrom).elements
    }
    
    func materialized(_ fetchFrom: FetchFrom = .default) -> (elements: [User], error: MyError?) {
        return materialized(fetchFrom: fetchFrom)
    }
}


final class CachingServiceFilterTests: XCTestCase {
    
    let dontCare: List<User>? = nil
    let empty: List<User>? = nil
    let userFooBar = User(userId: 0, firstName: "Foo", lastName: "Bar")
    let userBarBaz = User(userId: 1, firstName: "Bar", lastName: "Baz")
    let userBazBuz = User(userId: 3, firstName: "Baz", lastName: "Buz")
    let userBuzFoo = User(userId: 4, firstName: "Buz", lastName: "Foo")
    let userFooBaz = User(userId: 5, firstName: "Foo", lastName: "Baz")
    let userFooBuz = User(userId: 6, firstName: "Foo", lastName: "Buz")
    var initialCache: List<User> { return List([userFooBar, userBarBaz]) }
    var initialHttp: List<User> { return  List([userBazBuz, userBuzFoo, userFooBaz, userFooBuz]) }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testPersistingServiceFilterReturnsEmptyArrayForJibberishQueryButNonEmptyForProperQuery() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        var filterResult = userService.assertElements(Match(query: "qwerty"))
        XCTAssertEqual(filterResult.count, 0)
        filterResult = userService.assertElements(Match(query: "bar"))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 2)
    }
    
    func testPersistingServiceFilterReturnsEmptyArrayForNonMatchingCase() {
        let expected = ExpectedUserResult(cached: initialCache, http: initialHttp)
        let userService = MockedPersistingUserService(mocked: expected)
        let queryString = "bar"
        var filterResult = userService.assertElements(Match(query: queryString))
        XCTAssertEqual(filterResult.count, 1)
        XCTAssertEqual(filterResult[0].count, 2)
        filterResult = userService.assertElements(Match(query: queryString, caseSensitive: true))
        XCTAssertEqual(filterResult.count, 0)
    }
}
