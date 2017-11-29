//
//  Service+Blocking.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import SingleRxSignal
import XCTest
import RxSwift

final class MockedRouter: Router {
    var path: String { return "no router" }
}

extension Service {    
    func materialized<C: Codable>(fetchFrom: FetchFrom = .default) -> (elements: [C], error: MyError?) {
        let signal: Observable<C> = get(router: MockedRouter(), fetchFrom: fetchFrom)
        switch signal.toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? MyError else { XCTFail("failed to cast error"); return ([C](), nil) }
            return (elements, error)
        case .completed(let elements):
            return (elements, nil)
        }
    }
}

extension Persisting {
    func materialized<F: Codable & Filterable>(filter: QueryConvertible) -> (elements: [List<F>], error: MyError?) {
        print("type(of: F): `\(type(of: F.self))`")
        let signal: Observable<[F]> = get(filter: filter)
        switch signal.toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? MyError else { XCTFail("failed to cast error"); return ([List<F>](), nil) }
            return (elements.map { List($0) }, error)
        case .completed(let elements):
            return (elements.map { List($0) }, nil)
        }
    }
}
