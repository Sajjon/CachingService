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

protocol IntegerServiceProtocol: Service {
    func getInteger(fetchFrom: FetchFrom) -> Observable<Int>
}

extension IntegerServiceProtocol {
    func assertElements(_ fetchFrom: FetchFrom = .default) -> [Int] {
        return materialized(fetchFrom).elements
    }
    
    func materialized(_ fetchFrom: FetchFrom = .default) -> (elements: [Int], error: MyError?) {
        return materialized(fetchFrom: fetchFrom)
    }
}

