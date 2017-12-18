//
//  Collection+Filterable.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension Collection where Element: Filterable {
    func mapToFilterResult(using filter: FilterConvertible) -> [FilterResultConvertible] {
        return flatMap { $0.isMatching(filter) }
    }
    
    func filter(using filter: FilterConvertible) -> [Element] {
        return mapToFilterResult(using: filter).flatMap { $0.filterable as? Element }
    }
}
