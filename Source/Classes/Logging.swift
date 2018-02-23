//
//  Logging.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-23.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import SwiftyBeaver

internal let log = makeLog()

func makeLog() -> SwiftyBeaver.Type {
    let log = SwiftyBeaver.self
    guard (log.destinations.filter { $0 is ConsoleDestination }.isEmpty) else { return log }
    let consoleDestination = ConsoleDestination(); consoleDestination.minLevel = .debug
    log.addDestination(consoleDestination)
    return log
}
