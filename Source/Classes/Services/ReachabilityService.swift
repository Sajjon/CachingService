//
//  ReachabilityService.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 10/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//import RxReachability
import Reachability
import RxCocoa
import RxSwift
import RxOptional

public typealias ReachabilityStatus = Reachability.Connection

public protocol ReachabilityServiceConvertible {
    var status: Observable<ReachabilityStatus> { get }
    var isReachable: Observable<Bool> { get }
    var isConnected: Observable<Void> { get }
    var isDisconnected: Observable<Void> { get }
}

public protocol ReachabilityServiceProtocol: ReachabilityServiceConvertible {
    var reachabilityChanged: Observable<Reachability> { get }
}

extension ReachabilityServiceProtocol {
    public var status: Observable<ReachabilityStatus> {
        return reachabilityChanged
            .map { $0.connection }
    }
}

extension ReachabilityServiceConvertible {
    public var isReachable: Observable<Bool> {
        return status.map { $0 != .none }
    }
    
    public var isConnected: Observable<Void> {
        return isReachable
            .filter { $0 }
            .map { _ in Void() }
    }
    
    public var isDisconnected: Observable<Void> {
        return isReachable
            .filter { !$0 }
            .map { _ in Void() }
    }
}

enum ReachabilityServiceError: Error {
    case failedToCreate
}

public final class ReachabilityService : ReachabilityServiceProtocol {
    
    public let reachabilityChanged: Observable<Reachability>
    private let _reachability: Reachability
    
    public init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        
        reachabilityChanged = Observable.create { observer in
            reachabilityRef.whenReachable = { reachability in
                backgroundQueue.async {
                    observer.onNext(reachability)
                }
            }
            
            reachabilityRef.whenUnreachable = { reachability in
                backgroundQueue.async {
                    observer.onNext(reachability)
                }
            }
            return Disposables.create()
        }
        
        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
    }
    
    deinit {
        _reachability.stopNotifier()
    }
}



