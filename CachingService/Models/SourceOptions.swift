//
//  SourceOptions.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

//typealias SourceOptions = [SourceOptionsItem]

//enum SourceOptionsItem {
//    case emitValue
//    case emitError
//    case shouldCache
//    case retyWhenReachable
////    init(emitValue: Bool = true, emitError: Bool = true, shouldCache: Bool = true) {
////        self.emitValue = emitValue
////        self.emitError = emitError
////        self.shouldCache = shouldCache
////    }
//}

//extension SourceOptions {
//    static var `default`: SourceOptions { return SourceOptions() }
//}

private var nextOptions = 0
struct SourceOptions: OptionSet {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(line: Int = #line) { // adding a default args works around and issue where the empty init was called by the system sometimes and exhusted the available options.
        rawValue = 1 << nextOptions
        nextOptions += 1
    }
}

extension SourceOptions {
    static let emitValue = SourceOptions()
    static let emitError = SourceOptions()
    static let shouldCache = SourceOptions()
    static let retryWhenReachable = SourceOptions()
//    static let emitErrorsFromBackend = SourceOptions()
//    static let emitErrorsFromCache = SourceOptions()
}

extension SourceOptions {
    static let `default`: SourceOptions = [.emitValue, .emitError, .shouldCache]
//    static let retrying: SourceOptions  =  SourceOptions.default.inserting(retryWhenReachable)
}

extension SetAlgebra {
    func removing(_ other: Self.Element) -> Self {
        var `self` = self
        self.remove(other)
        return self
    }
    
    func inserting(_ other: Self.Element) -> Self {
        var `self` = self
        self.insert(other)
        return self
    }
}

//
//precedencegroup SourceOptionsMergingPrecedence {
//    associativity: none
//    higherThan: LogicalConjunctionPrecedence
//}
//
//infix operator <<< : SourceOptionsMergingPrecedence
//func <<< (lhs: SourceOptions, rhs: SourceOptions) -> SourceOptions {
//    return lhs.union(rhs)
//}
//
//precedencegroup SourceOptionsRemovingPrecedence {
//    associativity: none
//    higherThan: LogicalConjunctionPrecedence
//}
//
//infix operator >>> : SourceOptionsRemovingPrecedence
//func >>> (lhs: SourceOptions, rhs: SourceOptions) -> SourceOptions {
//    var lhs = lhs
//    lhs.remove(rhs)
//    return lhs
//}

extension SourceOptions {
    var emitValue: Bool { return contains(.emitValue) }
    var emitError: Bool { return contains(.emitError) }
    var shouldCache: Bool { return contains(.shouldCache) }
    var retyWhenReachable: Bool { return contains(.retryWhenReachable) }
}
