//
//  ServiceOption.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-06.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

public typealias ServiceOptionsInfo = [ServiceOptionsInfoItem]
let ServiceEmptyOptionsInfo = [ServiceOptionsInfoItem]()

public enum ServiceRetry {
    case count(Int)
    case forever
    case timeout(TimeInterval)
}

extension ServiceRetry {
    func sameIgnoringAssociatedValue(_ other: ServiceRetry) -> Bool {
        switch (self, other) {
        case (.forever, .forever): return true
        case (.count, .count): return true
        default: return false
        }
    }
}

extension ServiceRetry {
    static let `default`: ServiceRetry = .forever
}

public enum ServiceOptionsInfoItem {
    case emitValue
    case emitError
    case shouldCache
    case ifCachedPreventDownload
    case retryWhenReachable(ServiceRetry)
}

extension Collection where Iterator.Element == ServiceOptionsInfoItem {
    static var `default`: ServiceOptionsInfo { return [.emitValue, .emitError, .shouldCache] }
    static var foreverRetrying: ServiceOptionsInfo { return `default`.appending(.retryWhenReachable(.forever)) }
}

extension RangeReplaceableCollection where Iterator.Element == ServiceOptionsInfoItem {
    func removing(_ other: ServiceOptionsInfoItem) -> [ServiceOptionsInfoItem] {
        return removeAllMatchesIgnoringAssociatedValue(other)
    }
    
    func inserting(_ other: ServiceOptionsInfoItem) -> [ServiceOptionsInfoItem] {
        return removing(other).appending(other)
    }
    
    func appending(_ other: Iterator.Element) -> Self {
        var `self` = self
        self.append(other)
        return self
    }
}

precedencegroup ItemComparisonPrecedence {
    associativity: none
    higherThan: LogicalConjunctionPrecedence
}

infix operator <== : ItemComparisonPrecedence

// This operator returns true if two `ServiceOptionsInfoItem` enum is the same, without considering the associated values.
func <== (lhs: ServiceOptionsInfoItem, rhs: ServiceOptionsInfoItem) -> Bool {
    switch (lhs, rhs) {
    case (.emitValue, .emitValue): return true
    case (.emitError, .emitError): return true
    case (.shouldCache, .shouldCache): return true
    case (.ifCachedPreventDownload, .ifCachedPreventDownload): return true
    case (.retryWhenReachable, .retryWhenReachable): return true
    default: return false
    }
}


extension Collection where Iterator.Element == ServiceOptionsInfoItem {
    
    func contains(_ item: ServiceOptionsInfoItem) -> Bool {
        return lastMatchIgnoringAssociatedValue(item) != nil
    }
    
    func lastMatchIgnoringAssociatedValue(_ target: Iterator.Element) -> Iterator.Element? {
        return reversed().first { $0 <== target }
    }
    
    func removeAllMatchesIgnoringAssociatedValue(_ target: Iterator.Element) -> [Iterator.Element] {
        return filter { !($0 <== target) }
    }
}

public extension Collection where Iterator.Element == ServiceOptionsInfoItem {
    
    public var ifCachedPreventDownload: Bool {
        return contains { $0 <== .ifCachedPreventDownload }
    }
    
    public var emitValue: Bool {
        return contains { $0 <== .emitValue }
    }
    
    public var emitError: Bool {
        return contains { $0 <== .emitError }
    }
    
    public var shouldCache: Bool {
        return contains { $0 <== .shouldCache }
    }
    
    public var shouldRetry: Bool { return retryWhenReachable != nil }
    
    public var retryWhenReachable: ServiceRetry? {
        guard
            let item = lastMatchIgnoringAssociatedValue(.retryWhenReachable(.default)),
            case .retryWhenReachable(let retryWhenReachable) = item
            else { return nil }
        return retryWhenReachable
    }
}
