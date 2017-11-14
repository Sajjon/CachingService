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
}


extension OptionSet {
    func notContains(_ element: Element) -> Bool { return !contains(element) }
}


/////////////////////////////////////
protocol RequestPermissionConvertible: OptionSet {
    var rawValue: Int { get }
    static var load: Self { get }
    static var emitErrorEvents: Self { get }
    static var emitNextEvents: Self { get }
}

extension RequestPermissionConvertible where RawValue == Int, Element == Self {
    var isPermittedToMakeRequest: Bool { return contains(.load) }
    var isPermittedToEmitErrorEvents: Bool { return contains(.emitErrorEvents) }
    var isPermittedToEmitNextEvents: Bool { return contains(.emitNextEvents) }
}


private var nextCacheOptions = 0
struct CachePermissions {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(line: Int = #line) { // adding a default args works around and issue where the empty init was called by the system sometimes and exhusted the available options.
        rawValue = 1 << nextCacheOptions
        nextCacheOptions += 1
    }
}

extension CachePermissions {
    static let save = CachePermissions()
}

extension CachePermissions {
    var isPermittedToSave: Bool { return contains(.save) }
}

extension CachePermissions: RequestPermissionConvertible {
    static let load = CachePermissions()
    static let emitErrorEvents = CachePermissions()
    static let emitNextEvents = CachePermissions()
}
extension CachePermissions {
    static var `default`: CachePermissions { return [.load, .emitNextEvents, .save] }
}

private var nextBackendPermission = 0
struct BackendPermissions {
    let rawValue: Int
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(line: Int = #line) { // adding a default args works around and issue where the empty init was called by the system sometimes and exhusted the available options.
        rawValue = 1 << nextBackendPermission
        nextBackendPermission += 1
    }
}
extension BackendPermissions: RequestPermissionConvertible {
    static let load = BackendPermissions()
    static let emitErrorEvents = BackendPermissions()
    static let emitNextEvents = BackendPermissions()
}
extension BackendPermissions {
    static var `default`: BackendPermissions { return [.load, .emitNextEvents] }
}

struct RequestPermissions {
    let cachePermissions: CachePermissions
    let backendPermissions: BackendPermissions
    init(cachePermissions: CachePermissions = .default, backendPermissions: BackendPermissions = .default) {
        self.cachePermissions = cachePermissions
        self.backendPermissions = backendPermissions
    }
}

