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

private extension Service {
    
    func fetchFromBackendIfAbleCache<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        return fetchFromBackend(options: options).map { (modelFromAPI: C) in
            guard let persisting = self as? Persisting else { return modelFromAPI }
            do {
                print("Persisting `\(modelFromAPI)`")
                try persisting.cache.save(modelFromAPI)
            } catch { print("Failed to persist model: `\(modelFromAPI)`, error - `\(error)`") }
            return modelFromAPI
        }
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
        
        return persisting.load().catchError {
            guard options.catchErrorsFromCache else { return Observable.error($0) }
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
//    let cache: Cache = UserDefaults.standard
    let httpClient = HTTPClient()
    func getGroup(options: ObserverOptions = .default) -> Observable<Group> {
        return get(options: options)
    }
}


struct HTTPClient {
    func makeRequest<C>() -> Maybe<C> where C: NameOwner {
        return Maybe.create { maybe in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                let any: Any = C.self
                let model: C
                switch any {
                case is User.Type:
                    model = User(name: randomName()) as! C
                case is Group.Type:
                    model = Group(name: randomName()) as! C
                default: fatalError("non of the above")
                }
                maybe(.success(model))
            }
            return Disposables.create()
        }
    }
}
