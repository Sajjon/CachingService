//
//  Cache.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

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

let cacheKeyName = "name"

private extension Cache {
    func assertBackgroundThread() {
        guard !Thread.isMainThread else { fatalError("Run on main thread") }
    }
    
    func simulateCacheDelay() {
        assertBackgroundThread()
        delay(.cache)
    }
}

extension UserDefaults: AsyncCache {
    
    func load<C>() -> C? where C: NameOwner {
        simulateCacheDelay()
        guard let name = string(forKey: cacheKeyName) else { return nil }
        return C.init(name: name)
    }
    
    func save<C>(_ data: C) throws where C: NameOwner {
        simulateCacheDelay()
        self.set(data.name, forKey: cacheKeyName)
    }
    
    func deleteValueFor(key: String) {
        simulateCacheDelay()
        self.removeObject(forKey: key)
    }
    
    func hasValueForKey(key: String) -> Bool {
        simulateCacheDelay()
        return self.object(forKey: key) != nil
    }
}

protocol Cache {
    func load<C>() -> C? where C: NameOwner
    func save<C>(_ data: C) throws where C: NameOwner
    func deleteValueFor(key: String)
    func hasValueForKey(key: String) -> Bool
}

enum Result<C> {
    case success(C)
    case error(MyError)
}

typealias Done<C> = (Result<C>) -> Void
var void: () { () }
protocol AsyncCache: Cache {
    func asyncLoad<C>(done: @escaping Done<C>) where C: NameOwner
    func asyncSave<C>(_ data: C, done: @escaping Done<Void>) where C: NameOwner
    func asyncDeleteValue(for key: String, done: @escaping Done<Void>)
    func asyncCheckIfValueExists(for key: String, done: @escaping Done<Bool>)
}

extension AsyncCache {
    func asyncLoad<C>(done: @escaping Done<C>) where C: NameOwner {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<C>
            print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): loading...")
            if let loaded: C = self.load() {
                result = .success(loaded)
            } else {
                result = .error(MyError.cacheEmpty)
            }
            DispatchQueue.main.async {
                print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): loaded")
                done(result)
            }
        }
    }
    
    func asyncSave<C>(_ data: C, done: @escaping Done<Void>) where C: NameOwner {
        DispatchQueue.global(qos: .userInitiated).async {
            print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): saving...")
            let result: Result<Void>
            do {
                try self.save(data)
                result = .success(void)
            } catch {
                result = .error(MyError.cacheSaving)
            }
            DispatchQueue.main.async {
                print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): saved")
                done(result)
            }
        }
    }
    
    func asyncDeleteValue(for key: String, done: @escaping Done<Void>) {
        DispatchQueue.global(qos: .userInitiated).async {
            print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): deleting...")
            let result: Result<Void>
            self.deleteValueFor(key: key)
            result = .success(void)
            DispatchQueue.main.async {
                print("Main thread: \(Thread.isMainThread) - \(Date.timeAsString): deleted")
                done(result)
            }
        }
    }
    
    func asyncCheckIfValueExists(for key: String, done: @escaping Done<Bool>) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result: Result<Bool>
            print("\(Date.timeAsString): about to read if has key from cache")
            let hasValue = self.hasValueForKey(key: key)
            print("\(Date.timeAsString): read if had key from cache")
            result = .success(hasValue)
            DispatchQueue.main.async {
                done(result)
            }
        }
    }
}

protocol Persisting {
    var cache: AsyncCache { get }
}

extension Persisting {
    func asyncLoad<C>() -> Observable<C> where C: NameOwner {
        return Observable.create { observer in
            self.cache.asyncLoad { (result: Result<C>) in
                switch result {
                case .success(let loadedFromCache):
                    observer.onNext(loadedFromCache)
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
            }.do(onNext: { print("Found in cache: `\($0)`") })
    }
    
    func asyncSave<C>(_ fromBackend: C) -> Observable<C> where C: NameOwner {
        return Observable.create { observer in
            self.cache.asyncSave(fromBackend) { savingResult in
                switch savingResult {
                case .success:
                    print("successfully async saved `\(fromBackend)` to cache")
                    observer.onNext(fromBackend)
                case .error(let error):
                    print("Failed to async save model to cache: `\(fromBackend)`, error - `\(error)`")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
