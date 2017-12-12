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

final class DefaultReachabilityService : ReachabilityServiceProtocol {
    
//    private let _reachabilitySubject: BehaviorSubject<ReachabilityStatus>
    
    let reachabilityChanged: Observable<Reachability>
    
//    var reachability: Observable<Reachability.Connection> {
//        return _reachabilitySubject.asObservable()
//    }
    
    let _reachability: Reachability
    
    init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
//        let reachabilitySubject = BehaviorSubject<Reachability.Connection>(value: .none)
        
        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")
        
        
        reachabilityChanged = Observable.create { observer in
            reachabilityRef.whenReachable = { reachability in
                backgroundQueue.async {
                    observer.onNext(reachability)
//                    let status: ReachabilityStatus = reachabilityRef.connection == .wifi ? .wifi : .cellular
//                    reachabilitySubject.on(.next(status))
                }
            }
            
            reachabilityRef.whenUnreachable = { reachability in
                backgroundQueue.async {
                    observer.onNext(reachability)
//                    reachabilitySubject.on(.next(.none))
                }
            }
            return Disposables.create()
        }
        
        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
//        _reachabilitySubject = reachabilitySubject
    }
    
    deinit {
        _reachability.stopNotifier()
    }
}



