//
//  ObserverOptions.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension OptionSet {
    func notContains(_ element: Element) -> Bool { return !contains(element) }
}

protocol Validatable {
    func validate() -> Bool
}

protocol RequestPermissionConvertible: OptionSet, Validatable {
    var rawValue: Int { get }
    static var load: Self { get }
    static var emitErrorEvents: Self { get }
}

extension RequestPermissionConvertible where RawValue == Int, Element == Self {
    var isPermittedToMakeRequest: Bool { return contains(.load) }
    var isPermittedToEmitErrorEvents: Bool { return contains(.emitErrorEvents) }
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
}
extension CachePermissions {
    static let `default`: CachePermissions = [.load, .save]
}

//MARK: Validateable
extension CachePermissions {
    func validate() -> Bool {
        return true
    }
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
    static let emitNextEventDirectly = BackendPermissions()
}

extension BackendPermissions {
    var isPermittedToEmitNextEvents: Bool { return contains(.emitNextEvents) }
}

//MARK: Validateable
extension BackendPermissions {
    func validate() -> Bool {
        switch (contains(.emitNextEvents), contains(.emitNextEventDirectly)) { case (false, true): print("Emit next?"); return false; default: break }
        return true
    }
}

extension BackendPermissions {
    static let `default`: BackendPermissions = [.load, .emitNextEvents]
}

struct RequestPermissions: Validatable {
    let cachePermissions: CachePermissions
    let backendPermissions: BackendPermissions
    
    init(cache: CachePermissions, backend: BackendPermissions) {
        self.cachePermissions = cache
        self.backendPermissions = backend
    }
    
    init(cache: CachePermissions) {
        self.init(cache: cache, backend: .default)
    }
    
    init(backend: BackendPermissions) {
        self.init(cache: .default, backend: backend)
    }
}

extension RequestPermissions {
    static let `default` = RequestPermissions(cache: .default, backend: .default)
}

extension RequestPermissions {
    func validate() -> Bool {
        if !(cachePermissions.contains(.load) || backendPermissions.isPermittedToEmitNextEvents) { print("WARNING: `onNext` will never be called, is this intentional?") }
        guard cachePermissions.isPermittedToMakeRequest || backendPermissions.isPermittedToMakeRequest else { return false }
        return true
    }
}

extension RequestPermissions {
    var shouldFetchFromBackend: Bool { return backendPermissions.isPermittedToMakeRequest }
    var shouldLoadFromCache: Bool { return cachePermissions.isPermittedToMakeRequest }
    var shouldSaveToCache: Bool { return cachePermissions.isPermittedToSave }
    var catchErrorsFromCache: Bool { return !cachePermissions.isPermittedToEmitErrorEvents }
    var callOnNextForFetched: Bool { return backendPermissions.isPermittedToEmitNextEvents }
    var intermediateOnNextCallForFetched: Bool { return backendPermissions.contains(.emitNextEventDirectly) }
}

//enum PermissionWrapper {
//    case cache(CachePermissions)
//    case backend(BackendPermissions)
//}
//
//extension RequestPermissions: ExpressibleByArrayLiteral {
//    typealias ArrayLiteralElement = PermissionWrapper
//    init(arrayLiteral: PermissionWrapper...) {
//        let cachePermissions: CachePermissions = arrayLiteral.flatMap { (element: PermissionWrapper) in
//            return element
////            guard case let .cache(permissions) = element else { return nil }
////            return permissions as CachePermissions
//        }
//        self.init(cachePermissions: cachePermissions, backendPermissions: .default)
//    }
//}

