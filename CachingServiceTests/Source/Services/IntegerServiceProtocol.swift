//
//  IntegerServiceProtocol.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import SingleRxSignal
import RxSwift
import XCTest

protocol IntegerServiceProtocol: Service {
    func getInteger(fetchFrom: FetchFrom) -> Observable<Int>
}

extension IntegerServiceProtocol {
    func assertElements(_ fetchFrom: FetchFrom = .default) -> [Int] {
        return materialized(fetchFrom).elements
    }
    
    func materialized(_ fetchFrom: FetchFrom = .default) -> (elements: [Int], error: MyError?) {
        switch getInteger(fetchFrom: fetchFrom).toBlocking().materialize() {
        case .failed(let elements, let generalError):
            guard let error = generalError as? MyError else { XCTFail("failed to cast error"); return ([Int](), nil) }
            return (elements, error)
        case .completed(let elements):
            return (elements, nil)
        }
    }
}
