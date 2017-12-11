//
//  ObservableType+Retry.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-11.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxReachability
import Reachability
import RxCocoa

public extension ObservableType {
    
    public func retryOnConnect(options: ServiceRetry?) -> Observable<E> {
        guard let options = options else { log.verbose("No retry options"); return self.asObservable() }
        switch options {
        case .forever:
            return retryWhen { _ in
                return Reachability.rx.isConnected
            }
        case .timeout(let timeout):
            return retryWhen { _ in
                return Reachability.rx.isConnected.timeout(timeout, scheduler: MainScheduler.asyncInstance)
            }
        case .count(let count):
            return self.retry(count)
        }
    }
}
