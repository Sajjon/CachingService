//
//  Service.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxOptional

protocol Service {
    var httpClient: HTTPClient { get }
    func get<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner
}

extension Service {
    func get<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        do { try options.validate() } catch { fatalError("Invalid options, error: \(error)") }
        let httpSignal: Observable<C> = fetchFromBackendIfAbleCache(options: options)
        let cacheSignal: Observable<C> = loadFromCacheIfAble(options: options)
        return Observable.merge([httpSignal, cacheSignal])
    }
}

public extension ObservableType {
    func filter(if condition: Bool) -> RxSwift.Observable<Self.E> {
        return self.filter { _ in return condition }
    }
}

private extension Service {
    
    func fetchFromBackendIfAbleCache<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        return fetchFromBackend(options: options).do(onNext: { fromBackend in
            guard let persisting = self as? Persisting else { return }
            guard options.shouldSaveToCache else { print("Preventing saving to cache"); return }
            do {
                print("Persisting `\(fromBackend)`")
                try persisting.cache.save(fromBackend)
            } catch { print("Failed to persist model: `\(fromBackend)`, error - `\(error)`") }
        }).filter(if: options.callOnNextForFetched)
    }
    
    func fetchFromBackend<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        guard options.shouldFetchFromBackend else { print("prevented fetch from backend"); return Observable.empty() }
        return httpClient.makeRequest().asObservable().do(onNext: { print("HTTP response `\($0)`") })
    }
}

extension Service {
    
    func loadFromCacheIfAble<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        guard options.shouldLoadFromCache else { print("prevented load from cache"); return Observable.empty() }
        guard let persisting = self as? Persisting else { return Observable.empty() }
        print("Checking cache...")
        return persisting.load().catchError {
            guard options.catchErrorsFromCache else { return Observable.error($0) }
            print("Cache was empty :(")
            return Observable.empty()
        }
    }
    
}

final class UserService: Service, Persisting {
    let cache: Cache = UserDefaults.standard
    let httpClient = HTTPClient()
    func getUser(options: ObserverOptions = .default) -> Observable<User> {
        return get(options: options)
    }
}

final class GroupService: Service {
    let httpClient = HTTPClient()
    func getGroup(options: ObserverOptions = .default) -> Observable<Group> {
        return get(options: options)
    }
}

