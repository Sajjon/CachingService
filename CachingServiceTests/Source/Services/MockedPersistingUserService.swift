//
//  MockedPersistingUserService.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import RxSwift

final class MockedPersistingUserService {
    let mockedUserHTTPClient: MockedUserHTTPClient
    let mockedUserCache: MockedCacheForUser
    
    init(httpClient: MockedUserHTTPClient, cache: MockedCacheForUser) {
        self.mockedUserHTTPClient = httpClient
        self.mockedUserCache = cache
    }
    
//    func filterUsers(_ filter: QueryConvertible) -> Observable<[User]> {
//        return get(filter: filter)
//    }
}

extension MockedPersistingUserService: Service {
    var httpClient: HTTPClientProtocol { return mockedUserHTTPClient }
}

extension MockedPersistingUserService: Persisting {
    var cache: AsyncCache { return mockedUserCache }
}

extension MockedPersistingUserService {
    convenience init(mocked: ExpectedUserResult) {
        self.init(
            httpClient: MockedUserHTTPClient(mockedEvent: mocked.httpEvent),
            cache: MockedCacheForUser(mockedEvent: mocked.cacheEvent)
        )
    }
}


extension User: Equatable {
    public static func ==(rhs: User, lhs: User) -> Bool {
        return rhs.userId == lhs.userId && rhs.name == lhs.name
    }
}

final class ExpectedUserResult: BaseExpectedResult<List<User>> {}


final class MockedCacheForUser: BaseMockedCache<List<User>> {
    init(mockedEvent: MockedEvent<List<User>>) {
        super.init(event: mockedEvent)
    }
    
    override func loadValue<_Value>(for key: Key) -> _Value? where _Value: Codable {
        guard let cachedValue = mockedValue else { return nil }
        let casted: _Value = cachedValue.elements as! _Value
        return casted
    }
}

final class MockedUserHTTPClient: BaseMockedHTTPClient<List<User>> {
    init(mockedEvent: MockedEvent<List<User>>) {
        super.init(mockedEvent: mockedEvent)
    }
}


extension MockedPersistingUserService {
    func assertElements(_ filter: QueryConvertible) -> [List<User>] {
        return materialized(filter: filter).elements
    }
    
    func materialized(_ filter: QueryConvertible) -> (elements: [List<User>], error: MyError?) {
        return materialized(filter: filter)
    }
}

struct List<Element: Equatable & Codable>: Equatable, Codable, Collection {
    
    /// Needed for conformance to `Collection`
    var startIndex: Int = 0
    
    //MARK: - Collection associatedtypes
    typealias Index = Int
    typealias Iterator = IndexingIterator<List>
    typealias Indices = DefaultIndices<List>
    
    var endIndex: Int { return count }
    var count: Int { return elements.count }
    var isEmpty: Bool { return elements.isEmpty }
    
    subscript (position: Int) -> Element { return elements[position] }
    
    func index(after index: Int) -> Int {
        guard index < endIndex else { return endIndex }
        return index + 1
    }
    
    func index(before index: Int) -> Int {
        guard index > startIndex else { return startIndex }
        return index - 1
    }
    
    let elements: [Element]
    init(_ elements: [Element]) {
        self.elements = elements
    }
    init(element: Element) {
        self.init([element])
    }
    static func ==<E>(lhs: List<E>, rhs: List<E>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs.elements, rhs.elements).map { $0 == $1 }.reduce(true) { $0 && $1 }
    }
}

