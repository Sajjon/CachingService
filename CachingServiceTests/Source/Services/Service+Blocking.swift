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
    func materialized<C: Codable>(fromSource source: ServiceSource = .default) -> (elements: [C], error: MyError?) {
        let signal: Observable<C> = get(request: MockedRouter(), from: source)
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
    func materialized<F: Codable & Filterable>(filter: QueryConvertible, removeEmptyArrays: Bool = true) -> (elements: [List<F>], error: MyError?) {
        let signal: Observable<[F]> = get(filter: filter, removeEmptyArrays: removeEmptyArrays)
        switch signal.toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? MyError else { XCTFail("failed to cast error"); return ([List<F>](), nil) }
            return (elements.map { List($0) }, error)
        case .completed(let elements):
            return (elements.map { List($0) }, nil)
        }
    }
}
