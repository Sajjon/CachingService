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
    
    func get<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable
    
    func saveToOrDeleteInCacheIfAbleTo<C>(_ fromBackend: C?, fetchFrom: FetchFrom) -> Observable<C?> where C: Codable
    func loadFromCacheIfAbleTo<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable
}

extension Service {
    func get<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        log.verbose("Start")
        let cacheSignal: Observable<C> = loadFromCacheIfAbleTo(fetchFrom: fetchFrom)
        let httpSignal: Observable<C> = fetchFromBackendAndCacheIfAbleTo(fetchFrom: fetchFrom)
        return cacheSignal.concat(httpSignal)
    }
    
    func fetchFromBackendAndCacheIfAbleTo<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        log.error("Start")
        return fetchFromBackend(fetchFrom: fetchFrom)
            .catchError { self.handleError($0, fetchFrom: fetchFrom) }
            .flatMap { self.saveToOrDeleteInCacheIfAbleTo($0, fetchFrom: fetchFrom) }
            .filterNil()
            .filter(include: fetchFrom.emitEventForValueFromBackend)
            .do(onNext: { log.verbose("Got: \($0)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.info("onCompleted") })
    }
    
    func handleError<C>(_ error: Error, fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        guard fetchFrom.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("HTTP failed with error: `\(error)`, suppressed by service")
        return .empty()
    }

    func saveToOrDeleteInCacheIfAbleTo<C>(_ fromBackend: C?, fetchFrom: FetchFrom) -> Observable<C?> where C: Codable {
        guard !(self is Persisting) else { fatalError("Service is persisting but wrong `saveToOrDeleteInCacheIfAbleTo` got called") }
        return Observable.just(fromBackend)
    }

    func loadFromCacheIfAbleTo<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        guard !(self is Persisting) else { fatalError("Service is persisting but wrong `loadFromCacheIfAbleTo` got called") }
        return .empty()
    }
}

public extension ObservableType {
    func filter(include condition: Bool) -> RxSwift.Observable<Self.E> {
        return self.filter { _ in return condition }
    }
}

private extension Service {
    func fetchFromBackend<C>(fetchFrom: FetchFrom) -> Observable<C?> where C: Codable {
        log.error("Start")
        guard fetchFrom.shouldFetchFromBackend else { log.info("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest()
            .do(onNext: { var s = "empty"; if let d = $0 { s = "\(d)" }; log.verbose("HTTP response: \(s)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.info("onCompleted") })
    }
}

extension Service where Self: Persisting {
    
    func saveToOrDeleteInCacheIfAbleTo<C>(_ fromBackend: C?, fetchFrom: FetchFrom) -> Observable<C?> where C: Codable {
        guard !(fromBackend != nil && !fetchFrom.shouldSaveToCache) else { log.info("Prevented save to cache"); return .of(fromBackend!) }
        return asyncSaveOrDelete(fromBackend, key: KeyCreator<C>.key)
    }
    
    func loadFromCacheIfAbleTo<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        log.info("Start")
        guard fetchFrom.shouldLoadFromCache else { log.info("Prevented load from cache"); return .empty() }
        return asyncLoad().filterNil()
    }
}

protocol UserServiceProtocol: Service, Persisting {
    func getUser(fetchFrom: FetchFrom) -> Observable<User>
}

final class UserService: UserServiceProtocol {
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(httpClient: HTTPClientProtocol, cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
    
    func getUser(fetchFrom: FetchFrom = .default) -> Observable<User> {
        print("GETTING USER")
        return get(fetchFrom: fetchFrom)
    }
}

protocol GroupServiceProtocol: Service {
    func getGroup(fetchFrom: FetchFrom) -> Observable<Group>
}

final class GroupService: GroupServiceProtocol {
    let httpClient: HTTPClientProtocol = HTTPClient()
    func getGroup(fetchFrom: FetchFrom = .default) -> Observable<Group> {
        return get(fetchFrom: fetchFrom)
    }
}
