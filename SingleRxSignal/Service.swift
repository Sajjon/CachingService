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
    func get<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner
    
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: ObserverOptions) -> Observable<C> where C: NameOwner
}

extension Service {
    func get<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        do { try options.validate() } catch { fatalError("Invalid options, error: \(error)") }
        let httpSignal: Observable<C> = fetchFromBackendAndCacheIfAbleTo(options: options)
        let cacheSignal: Observable<C> = loadFromCacheIfAbleTo(options: options)
        return Observable.merge([httpSignal, cacheSignal]) // TODO compare: Observable.of(httpSignal, cacheSignal).merge()
    }
    
    func fetchFromBackendAndCacheIfAbleTo<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        return fetchFromBackend(options: options)
            .flatMap { self.saveToCacheIfNeeded($0, options: options) }
            .filter(if: options.callOnNextForFetched)
    }
    
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: ObserverOptions) -> Observable<C> where C: NameOwner {
        return .of(fromBackend)
    }
}

public extension ObservableType {
    func filter(if condition: Bool) -> RxSwift.Observable<Self.E> {
        return self.filter { _ in return condition }
    }
}

private extension Service {
    func fetchFromBackend<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        guard options.shouldFetchFromBackend else { print("prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest().asObservable().do(onNext: { print("HTTP response `\($0)`") })
    }
}

extension Service where Self: Persisting {
    @discardableResult
    func saveToCacheIfNeeded<C>(_ fromBackend: C, options: ObserverOptions) -> Observable<C> where C: NameOwner {
        guard options.shouldSaveToCache else { print("Prevented save to cache"); return .of(fromBackend) }
        return asyncSave(fromBackend)
    }
}

extension Service {
    
    func loadFromCacheIfAbleTo<C>(options: ObserverOptions) -> Observable<C> where C: NameOwner {
        guard options.shouldLoadFromCache else { print("prevented load from cache"); return .empty() }
        guard let persisting = self as? Persisting else { return .empty() }
        print("Checking cache...")
        return persisting.asyncLoad().catchError {
            guard options.catchErrorsFromCache else { return .error($0) }
            print("Cache was empty :(")
            return .empty()
        }
    }
    
}

final class UserService: Service, Persisting {
    
    let cache: AsyncCache = UserDefaults.standard
    let httpClient: HTTPClientProtocol = HTTPClient()
    func getUser(options: ObserverOptions = .default) -> Observable<User> {
        return get(options: options)
    }
}

final class GroupService: Service {
    let httpClient: HTTPClientProtocol = HTTPClient()
    func getGroup(options: ObserverOptions = .default) -> Observable<Group> {
        return get(options: options)
    }
}

