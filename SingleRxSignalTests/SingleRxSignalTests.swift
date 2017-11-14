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

func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...100) -> T {
    let length = Int64(range.upperBound - range.lowerBound + 1)
    let value = Int64(arc4random()) % length + Int64(range.lowerBound)
    return T(value)
}

extension Int {
    static func random(max: Int) -> Int { return randomNumber(inRange: 1...max) }
}

extension Int: StaticKeyConvertible {
    public static var key: Key { return "integer" }
}

//func getDataFromCacheAndOrBackend(emitExtraNextEventBeforeCachingDone emitNextEvent: Bool) -> Observable<Int> {
//    return getDataFromBackend().flatMap(emitNextEventBeforeMap: emitNextEvent) { self.asyncSaveToCache(dataFromBackend: $0) }
//}
//
//func getDataFromBackend() -> Observable<Int> {
//    return Observable.just(42).delay(2, scheduler: MainScheduler.instance)
//        .do(onNext: { print("http response: `\($0)`") })
//}
//
//func asyncSaveToCache(dataFromBackend: Int) -> Observable<Int> {
//    return Observable.just(dataFromBackend).delay(1, scheduler: MainScheduler.instance)
//        .do(onNext: { print("cached: `\($0)`") })
//}

final class MockedHTTPClient: HTTPClientProtocol {
    func makeRequest<C>() -> Maybe<C> where C: Codable {
        let value: C = Int.random(max: 100) as! C
        return Maybe.just(value).delay(0.02, scheduler: MainScheduler.instance)
    }
}

protocol IntegerServiceProtocol: Service {
    func getInteger(options: RequestPermissions) -> Observable<Int>
}

final class MockedPersistingIntegerService: IntegerServiceProtocol, Persisting {
    let cache: AsyncCache = MockedCacheForInteger()
    let httpClient: HTTPClientProtocol
    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    func getInteger(options: RequestPermissions) -> Observable<Int> {
        return get(options: options)
    }
}

final class MockedCacheForInteger: AsyncCache {
    var savedInteger: Int?
    func save<Value>(value: Value, for key: Key) throws where Value: Codable {
        print("mocking saving")
        savedInteger = (value as! Int)
    }
    func loadValue<Value>(for key: Key) -> Value? where Value: Codable {
        print("mocking loading")
        guard let saved = savedInteger else { return nil }
        return saved as! Value
    }
    func hasValue(for key: Key) -> Bool { return savedInteger != nil }
    func deleteValue(for key: Key) { savedInteger = nil }
    
}

class SingleRxSignalTests: XCTestCase {
    
    let integerService: IntegerServiceProtocol = MockedPersistingIntegerService(httpClient: MockedHTTPClient())
    let bag = DisposeBag()
    
    func testSimple() {
        integerService.getInteger(options: .default).subscribe(onNext: {
            print("Subscriber got: \($0)")
        }).disposed(by: bag)
        //, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
    }
}
