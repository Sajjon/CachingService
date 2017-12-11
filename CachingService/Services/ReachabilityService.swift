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


//#if swift(>=3.2)
//    import class Dispatch.DispatchQueue
//#else
//    import class Dispatch.queue.DispatchQueue
//#endif
//
//public enum ReachabilityStatus {
//    case reachable(viaWiFi: Bool)
//    case unreachable
//}

//extension Reachability.Connection: Equatable {
//    public static func ==(lhs: Reachability.Connection, rhs: Reachability.Connection) -> Bool {
//        switch (lhs, rhs) {
//        case (.none, .none): return true
//        case (.wifi, .wifi): return true
//        case (.cellular, .cellular): return true
//        default: return false
//        }
//    }
//}
//
//extension ReachabilityStatus {
//    var reachable: Bool {
//        switch self {
//        case .reachable:
//            return true
//        case .unreachable:
//            return false
//        }
//    }
//}

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
//                let next: Reachability.Connection = reachabilityRef.connection == .wifi ? .wifi : .cellular
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


