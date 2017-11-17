//
//  Service.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

protocol Service {
    var httpClient: HTTPClientProtocol { get }
    func get<C>(options: RequestPermissions) -> Observable<C> where C: Codable
    
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: RequestPermissions) -> Observable<C> where C: Codable
}

extension Service {
    func get<C>(options: RequestPermissions) -> Observable<C> where C: Codable {
        guard options.validate() else { fatalError("Invalid options)") }
        let httpSignal: Observable<C> = fetchFromBackendAndCacheIfAbleTo(options: options)
        let cacheSignal: Observable<C> = loadFromCacheIfAbleTo(options: options)
        return Observable.merge([httpSignal, cacheSignal]) // TODO compare: Observable.of(httpSignal, cacheSignal).merge()
    }
    
    func fetchFromBackendAndCacheIfAbleTo<C>(options: RequestPermissions) -> Observable<C> where C: Codable {
        return fetchFromBackend(options: options)
            .catchError {
                guard options.catchErrorsFromBackend else { return .error($0) }
                print("HTTP failed with error: `\($0)`, suppressed by service")
                return .empty()
            }
            .flatMap(emitNextEventBeforeMap: options.intermediateOnNextCallForFetched) { self.saveToCacheIfNeeded($0, options: options) }
            .filter(if: options.callOnNextForFetched)
    }
    
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: RequestPermissions) -> Observable<C> where C: Codable {
        guard !(self is Persisting) else { fatalError("Service is persisting but wrong `saveToCacheIfNeeded` got called") }
        return .of(fromBackend)
    }
}

public extension ObservableType {
    func filter(if condition: Bool) -> RxSwift.Observable<Self.E> {
        return self.filter { _ in return condition }
    }
}

private extension Service {
    func fetchFromBackend<C>(options: RequestPermissions) -> Observable<C> where C: Codable {
        guard options.shouldFetchFromBackend else { print("prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest().asObservable().do(onNext: { print("HTTP response `\($0)`") })
    }
}

extension Service where Self: Persisting {
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: RequestPermissions) -> Observable<C> where C: Codable {
        guard options.shouldSaveToCache else { print("Prevented save to cache"); return .of(fromBackend) }
        return asyncSave(fromBackend)
    }
}

extension Service {
    
    func loadFromCacheIfAbleTo<C>(options: RequestPermissions) -> Observable<C> where C: Codable {
        guard options.shouldLoadFromCache else { print("prevented load from cache"); return .empty() }
        guard let persisting = self as? Persisting else { return .empty() }
        print("Service: checking cache...")
        return persisting.asyncLoad().filterNil().catchError {
            guard options.catchErrorsFromCache else { return .error($0) }
            print("Service: cache was empty :(")
            return .empty()
        }
    }
    
}

protocol UserServiceProtocol: Service, Persisting {
    func getUser(options: RequestPermissions) -> Observable<User>
}

final class UserService: UserServiceProtocol {
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(httpClient: HTTPClientProtocol, cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getUser(options: RequestPermissions = .default) -> Observable<User> {
        print("GETTING USER")
        return get(options: options)
    }
}

protocol GroupServiceProtocol: Service {
    func getGroup(options: RequestPermissions) -> Observable<Group>
}

final class GroupService: GroupServiceProtocol {
    let httpClient: HTTPClientProtocol = HTTPClient()
    func getGroup(options: RequestPermissions = .default) -> Observable<Group> {
        return get(options: options)
    }
}
