//
//  IntegerServiceProtocol.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

@testable import CachingService
import RxSwift

protocol IntegerServiceProtocol: Service {
    func getInteger(fromSource source: ServiceSource) -> Observable<Int>
}

extension IntegerServiceProtocol {
    func assertElements(_ source: ServiceSource = .default) -> [Int] {
        return materialized(source).elements
    }
    
    func materialized(_ source: ServiceSource = .default) -> (elements: [Int], error: ServiceError?) {
        return materialized(fromSource: source)
    }
}

