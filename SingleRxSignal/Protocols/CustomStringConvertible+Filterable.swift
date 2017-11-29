//
//  CustomStringConvertible+Filterable.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-28.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension CustomStringConvertible {
    func contains(_ other: CustomStringConvertible, caseSensitive: Bool) -> Bool {
        guard
            let tuple: (needle: String, haystack: String) = ([self, other].map { $0.description }.map { caseSensitive ? $0 : $0.lowercased() }.firstAndLast())
            else { return false }
        return tuple.haystack.contains(tuple.needle)
    }
}

extension Array {
    func firstAndLast() -> (Element, Element)? {
        guard
            count > 1,
            let first = first,
            let last = last
            else { return nil }
        return (first, last)
    }
}
