//
//  SimulatedDelay.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

func threadTimePrint(_ message: String) {
    let threadString = Thread.isMainThread ? "MAIN THREAD" : "BACKGROUND THREAD"
    print("\(threadString) - \(Date.timeAsString): \(message)")
}


enum SimulatedDelay {
    case cache
    case http
}

extension SimulatedDelay {
    var time: TimeInterval {
        switch self {
        case .cache: return 2
        case .http: return 5
        }
    }
}

func delay(_ simulatedDelay: SimulatedDelay) {
    let sleepTime: UInt32 = UInt32(simulatedDelay.time)
    sleep(sleepTime)
}
