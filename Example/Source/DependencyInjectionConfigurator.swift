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
import Cache
import SwiftDate
import CachingService

private let bytesPerKilobyte: UInt = 1000
extension Int {
    /// Not Integer overflow safe
    var kilobytes: UInt { return UInt(self) * bytesPerKilobyte }
    /// Not Integer overflow safe
    var megabytes: UInt { return UInt(self) * kilobytes * bytesPerKilobyte }
}

struct DependencyInjectionConfigurator {
    static func registerDependencies() -> Container {
        return Container() { c in
            
            c.register(ReachabilityServiceConvertible.self) { _ in
                try! ReachabilityService()
            }.inObjectScope(.container)
            
            c.register(AsyncCache.self) { _ in
                let expiry: Expiry = .date(Date() + 2.day)
                let diskConfig = DiskConfig(name: "floppy", expiry: expiry, maxSize: 1.megabytes)
                let memoryConfig = MemoryConfig(expiry: expiry, countLimit: 10000, totalCostLimit: 0)
                return try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
            }.inObjectScope(.container)
            
            c.register(HTTPHeaderStoreProtocol.self) { _ in HTTPHeaderStore() }.inObjectScope(.container)
            
            c.register(EnvironmentsProtocol.self) { _ in
                Environments(infoPlist: Bundle.main.infoDictionary!)
            }.inObjectScope(.container)
            
            c.register(HTTPClientProtocol.self) { r in
                HTTPClient(
                    reachability: r.resolve(ReachabilityServiceConvertible.self)!,
                    environments: r.resolve(EnvironmentsProtocol.self)!,
                    httpHeaderStore: r.resolve(HTTPHeaderStoreProtocol.self)!
                )
            }.inObjectScope(.container)
            
            c.register(ImageServiceProtocol.self) { r in
                let expiry: Expiry = .date(Date() + 1.day)
                let diskConfig = DiskConfig(name: "imageCache", expiry: expiry, maxSize: 100.megabytes)
                let memoryConfig = MemoryConfig(expiry: expiry, countLimit: 1000, totalCostLimit: 0)
                let imageCache: AsyncCache = try! Storage(diskConfig: diskConfig, memoryConfig: memoryConfig)
                return ImageService(
                    httpClient: r.resolve(HTTPClientProtocol.self)!,
                    cache: imageCache
                )
            }.inObjectScope(.container)
            
            c.register(CoinServiceProtocol.self) { r in
                CoinService(
                    httpClient: r.resolve(HTTPClientProtocol.self)!,
                    cache: r.resolve(AsyncCache.self)!
                )
                }.inObjectScope(.weak)

            c.register(CoinsViewController.self) { (r, presenter: UINavigationController) in
                CoinsViewController(
                    coinService: r.resolve(CoinServiceProtocol.self)!,
                    imageService: r.resolve(ImageServiceProtocol.self)!,
                    presenter: presenter
                )
                }.inObjectScope(.weak)
        }
    }
}
