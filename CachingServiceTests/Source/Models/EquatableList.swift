//
//  EquatableList.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-29.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation


struct List<Element: Equatable & Codable>: Equatable, Codable, Collection {
    
    /// Needed for conformance to `Collection`
    var startIndex: Int = 0
    
    //MARK: - Collection associatedtypes
    typealias Index = Int
    typealias Iterator = IndexingIterator<List>
    typealias Indices = DefaultIndices<List>
    
    var endIndex: Int { return count }
    var count: Int { return elements.count }
    var isEmpty: Bool { return elements.isEmpty }
    
    subscript (position: Int) -> Element { return elements[position] }
    
    func index(after index: Int) -> Int {
        guard index < endIndex else { return endIndex }
        return index + 1
    }
    
    func index(before index: Int) -> Int {
        guard index > startIndex else { return startIndex }
        return index - 1
    }
    
    let elements: [Element]
    init(_ elements: [Element]) {
        self.elements = elements
    }
    init(element: Element) {
        self.init([element])
    }
    static func ==<E>(lhs: List<E>, rhs: List<E>) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs.elements, rhs.elements).map { $0 == $1 }.reduce(true) { $0 && $1 }
    }
}
