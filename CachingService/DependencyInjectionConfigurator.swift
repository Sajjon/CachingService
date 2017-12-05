//
//  DependencyInjectionConfigurator.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Swinject
import RxSwift

struct DependencyInjectionConfigurator {
    static func registerDependencies() -> Container {
        return Container() { c in
            
            c.register(ReachabilityService.self) { _ in
                try! DefaultReachabilityService()
            }.inObjectScope(.container)
            
            c.register(ImageService.self) { r in
                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 2
                operationQueue.qualityOfService = QualityOfService.userInitiated
                let backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
                
                return DefaultImageService(
                    reachabilityService: r.resolve(ReachabilityService.self)!,
                    urlSession: Foundation.URLSession.shared,
                    backgroundWorkScheduler: backgroundWorkScheduler,
                    mainScheduler: MainScheduler.instance)
            }.inObjectScope(.container)
                
            c.register(AsyncCache.self) { _ in UserDefaults.standard }.inObjectScope(.container)
            
            c.register(HTTPHeaderStoreProtocol.self) { _ in HTTPHeaderStore() }.inObjectScope(.container)
            
            c.register(EnvironmentsProtocol.self) { _ in
                Environments(infoPlist: Bundle.main.infoDictionary!)
            }.inObjectScope(.container)
            
            c.register(HTTPClientProtocol.self) { r in
                HTTPClient(
                    environments: r.resolve(EnvironmentsProtocol.self)!,
                    httpHeaderStore: r.resolve(HTTPHeaderStoreProtocol.self)!
                )
            }.inObjectScope(.container)
            
            c.register(CoinServiceProtocol.self) { r in
                CoinService(
                    reachability: r.resolve(ReachabilityService.self)!,
                    httpClient: r.resolve(HTTPClientProtocol.self)!,
                    cache: r.resolve(AsyncCache.self)!
                )
                }.inObjectScope(.weak)
            
            c.register(MenuViewController.self) { (r, presenter: UINavigationController) in
                MenuViewController(
                    coinService: r.resolve(CoinServiceProtocol.self)!,
                    imageService: r.resolve(ImageService.self)!,
                    presenter: presenter
                )
                }.inObjectScope(.weak)
        }
    }
}
