//
//  Dependencies.swift
//  RxExample
//
//  Created by carlos on 13/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

import class Foundation.URLSession
import class Foundation.OperationQueue
import enum Foundation.QualityOfService

class Dependencies {

    let URLSession = Foundation.URLSession.shared
    let backgroundWorkScheduler: ImmediateSchedulerType
    let mainScheduler: SerialDispatchQueueScheduler
    
    private init() {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        mainScheduler = MainScheduler.instance
    }
    
}
