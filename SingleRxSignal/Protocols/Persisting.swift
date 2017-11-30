//
//  Persisting.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

protocol Persisting {
    var cache: AsyncCache { get }
    func get<Model>(filter: QueryConvertible, removeEmptyArrays: Bool) -> Observable<[Model]> where Model: Codable & Filterable
}

extension Persisting {
    func get<Model>(filter: QueryConvertible, removeEmptyArrays: Bool) -> Observable<[Model]> where Model: Codable & Filterable {
        return asyncLoad()
            .filterNil()
            .filterValues(by: filter, removeEmptyArrays: removeEmptyArrays)
    }
}

extension Observable where E: Collection, E.Element: Filterable  {
    typealias F = E.Element
    func filterValues(by filter: QueryConvertible, removeEmptyArrays: Bool = true) -> RxSwift.Observable<Element> {
        let filterMatch: (E) -> (E) = { ($0 as! [F]).filtered(by: filter) as! E }
        let filterEmpty: (E) -> Bool = { !removeEmptyArrays || !$0.isEmpty }
        
        return map { filterMatch($0) }.filter { filterEmpty($0) }
    }
}
