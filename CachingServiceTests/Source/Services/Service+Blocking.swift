//
//  Service+Blocking.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
@testable import CachingService
import XCTest
import RxSwift

final class MockedRouter: Router {
    var path: String { return "no router" }
}

extension Service {    
    func materialized<C: Codable>(fromSource source: ServiceSource = .default) -> (elements: [C], error: ServiceError?) {
        let signal: Observable<C> = get(request: MockedRouter(), from: source)
        switch signal.toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? ServiceError else { XCTFail("failed to cast error"); return ([C](), nil) }
            return (elements, error)
        case .completed(let elements):
            return (elements, nil)
        }
    }
}

extension Persisting {
    func materialized<F: Codable & Filterable>(filter: FilterConvertible, removeEmptyArrays: Bool = true) -> (elements: [List<F>], error: ServiceError?) {
        let filterEmpty: ([F]) -> Bool = { !removeEmptyArrays || !$0.isEmpty }

        let signal: Observable<[F]> = getModels(using: filter).filter { filterEmpty($0) }
        switch signal.toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? ServiceError else { XCTFail("failed to cast error"); return ([List<F>](), nil) }
            return (elements.map { List($0) }, error)
        case .completed(let elements):
            return (elements.map { List($0) }, nil)
        }
    }
}
