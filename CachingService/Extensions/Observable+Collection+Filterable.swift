//
//  Observable+Collection+Filterable.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

extension Observable where E: Collection, E.Element: Filterable  {
    typealias F = E.Element
    func filterValues(using filter: FilterConvertible) -> RxSwift.Observable<Element> {
        let filterMatch: (E) -> (E) = { ($0 as! [F]).filter(using: filter) as! E }
        return map { filterMatch($0) }
    }
}
