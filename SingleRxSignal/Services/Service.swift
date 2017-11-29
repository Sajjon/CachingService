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

extension Observable where Element: Collection, Element.Element: Filterable  {

    func filterValues(by filter: QueryConvertible) -> RxSwift.Observable<Element> {
        let filtered: Observable<Element> = map { ($0 as! [Element.Element]).filtered(by: filter) as! Element }
        return filtered.filter { !$0.isEmpty }
    }
}

protocol Service {
    var httpClient: HTTPClientProtocol { get }
    func get<C>(router: Router, fetchFrom: FetchFrom) -> Observable<C> where C: Codable
}

extension User {
    var _primaryKeyPath: PartialKeyPath<User> { return \.name }
    var primaryKeyPath: KeyPath<User, String> { return \.name }
    var keyPaths: [KeyPath<User, String>] { return [primaryKeyPath] }
}

protocol Persisting {
    var cache: AsyncCache { get }
    func get<F>(filter: QueryConvertible) -> Observable<[F]> where F: Codable & Filterable
}

extension Persisting {
    func get<F>(filter: QueryConvertible) -> Observable<[F]> where F: Codable & Filterable {
        return asyncLoad()
            .filterNil()
            .filterValues(by: filter)
    }
}

extension Service {
    func get<C>(router: Router, fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        let cacheSignal: Observable<C> = loadFromCacheIfAbleTo(fetchFrom: fetchFrom)
        let httpSignal: Observable<C> = fetchFromBackendAndCacheIfAbleTo(router: router, fetchFrom: fetchFrom)
        return cacheSignal.concat(httpSignal)
    }
}

//MARK: - Private Methods
private extension Service {
    
    func fetchFromBackendAndCacheIfAbleTo<C>(router: Router, fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        return fetchFromBackend(router: router, fetchFrom: fetchFrom)
            .catchError { self.handleError($0, fetchFrom: fetchFrom) }
            .flatMap { self.saveToOrDeleteInCacheIfAbleTo($0, fetchFrom: fetchFrom) }
            .filterNil()
            .filter(include: fetchFrom.emitEventForValueFromBackend)
            .do(onNext: { log.verbose("Got: \($0)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func fetchFromBackend<C>(router: Router, fetchFrom: FetchFrom) -> Observable<C?> where C: Codable {
        guard fetchFrom.shouldFetchFromBackend else { log.info("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest(router: router)
            .do(onNext: { var s = "empty"; if let d = $0 { s = "\(d)" }; log.verbose("HTTP response: \(s)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func saveToOrDeleteInCacheIfAbleTo<C>(_ fromBackend: C?, fetchFrom: FetchFrom) -> Observable<C?> where C: Codable {
        guard let persisting = self as? Persisting else { return .just(fromBackend) }
        guard !(fromBackend != nil && !fetchFrom.shouldSaveToCache) else { log.info("Prevented save to cache"); return .of(fromBackend!) }
        return persisting.asyncSaveOrDelete(fromBackend, key: KeyCreator<C>.key)
        
    }
    
    func loadFromCacheIfAbleTo<C>(fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        guard let persisting = self as? Persisting else { return .empty() }
        guard fetchFrom.shouldLoadFromCache else { log.info("Prevented load from cache"); return .empty() }
        return persisting.asyncLoad()
            .filterNil()
    }
    
    func handleError<C>(_ error: Error, fetchFrom: FetchFrom) -> Observable<C> where C: Codable {
        guard fetchFrom.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("HTTP failed with error: `\(error)`, suppressed by service")
        return .empty()
    }
}

