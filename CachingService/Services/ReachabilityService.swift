//
//  ReachabilityService.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 10/22/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxReachability
import Reachability
import RxCocoa
import RxSwift
import RxOptional

public typealias ReachabilityStatus = Reachability.Connection

public protocol ReachabilityService {
    var reachability: Observable<Reachability.Connection> { get }
}

enum ReachabilityServiceError: Error {
    case failedToCreate
}

final class DefaultReachabilityService : ReachabilityService {

    private let _reachabilitySubject: BehaviorSubject<Reachability.Connection>

    var reachability: Observable<Reachability.Connection> {
        return _reachabilitySubject.asObservable()
    }

    let _reachability: Reachability

    init() throws {
        guard let reachabilityRef = Reachability() else { throw ReachabilityServiceError.failedToCreate }
        let reachabilitySubject = BehaviorSubject<Reachability.Connection>(value: .none)

        // so main thread isn't blocked when reachability via WiFi is checked
        let backgroundQueue = DispatchQueue(label: "reachability.wificheck")

        reachabilityRef.whenReachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(reachabilityRef.connection == .wifi ? .wifi : .cellular))
            }
        }

        reachabilityRef.whenUnreachable = { reachability in
            backgroundQueue.async {
                reachabilitySubject.on(.next(.none))
            }
        }

        try reachabilityRef.startNotifier()
        _reachability = reachabilityRef
        _reachabilitySubject = reachabilitySubject
    }

    deinit {
        _reachability.stopNotifier()
    }
}


