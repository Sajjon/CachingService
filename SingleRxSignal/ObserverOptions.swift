//
//  ObserverOptions.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation


private var nextOptions = 0
struct ObserverOptions: OptionSet {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(line: Int = #line) { // adding a default args works around and issue where the empty init was called by the system sometimes and exhusted the available options.
        rawValue = 1 << nextOptions
        nextOptions += 1
    }
}

extension ObserverOptions {
    static let preventLoadingFromCache = ObserverOptions()
    static let preventSavingToCache = ObserverOptions()
    static let preventFetchFromBackend = ObserverOptions()
    static let preventFetchFromBackendOnlyIfCached = ObserverOptions()
    static let preventOnNextForFetched = ObserverOptions()
    static let emitErrorsFromBackend = ObserverOptions()
    static let emitErrorsFromCache = ObserverOptions()
    
    static let `default`: ObserverOptions = []
}

extension ObserverOptions {
    var preventLoadingFromCache: Bool { return contains(.preventLoadingFromCache) }
    var preventSavingToCache: Bool { return contains(.preventSavingToCache) }
    var preventFetchFromBackend: Bool { return contains(.preventFetchFromBackend) }
    var preventOnNextForFetched: Bool { return contains(.preventOnNextForFetched) }
    var emitErrorsFromBackend: Bool { return contains(.emitErrorsFromBackend) }
    var emitErrorsFromCache: Bool { return contains(.emitErrorsFromCache) }
}

extension ObserverOptions {
    func validate() throws {
        if preventLoadingFromCache && preventOnNextForFetched { print("WARNING: `onNext` will never be called, is this intentional?") }
        guard shouldLoadFromCache || shouldFetchFromBackend else { throw MyError.invalidOptions }
        return
    }
}

extension ObserverOptions {
    var shouldLoadFromCache: Bool { return !preventLoadingFromCache }
    var shouldSaveToCache: Bool { return !preventSavingToCache }
    var shouldFetchFromBackend: Bool { return !preventFetchFromBackend }
    var callOnNextForFetched: Bool { return !preventOnNextForFetched }
    var catchHTTPErrors: Bool {return !emitErrorsFromBackend }
    var catchErrorsFromCache: Bool {return !emitErrorsFromCache }
//    var fetchEvenIfFoundCached: Bool { return true }
}


extension OptionSet {
    func notContains(_ element: Element) -> Bool { return !contains(element) }
}
