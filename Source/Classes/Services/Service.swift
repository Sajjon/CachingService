//
//  Service.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire
//import RxReachability
import Reachability
import RxCocoa
import RxSwift
import RxOptional
import Cache
import SwiftyBeaver

internal let log = makeLog()
func makeLog() -> SwiftyBeaver.Type {
    let log = SwiftyBeaver.self
    let consoleDestination = ConsoleDestination(); consoleDestination.minLevel = .debug
    log.addDestination(consoleDestination)
    return log
}


extension URL: Key {}
public extension URL {
    var identifier: String { return absoluteString }
}

public protocol Service {
    var httpClient: HTTPClientProtocol { get }
    func get<Model>(request: Router, from source: ServiceSource, key: Key?) -> Observable<Model> where Model: Codable
    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model?> where Model: Codable
    func getFromCacheIfAbleTo<Model>(from source: ServiceSource, key: Key?) -> Observable<Model?> where Model: Codable
}

//MARK: - Default Implementation
public extension Service {
    func get<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        return get(request: request, from: source, key: nil)
    }
    
    func get<Model>(request: Router, from source: ServiceSource, key: Key?) -> Observable<Model> where Model: Codable {
        return getFromCacheIfAbleTo(from: source, key: key)
            .flatMap { (maybeModel: Model?) -> Observable<Model> in
                if let model = maybeModel, source.ifCachedPreventDownload {
                    return .just(model)
                } else {
                    return Observable.from(optional: maybeModel).concat(self.getFromBackendAndCacheIfAbleTo(request: request, from: source, key: key))
                }
        }
    }
    
    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model?> where Model: Codable {
        guard source.shouldFetchFromBackend else { log.debug("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest(request: request)
            .do(onNext: { let s: String = ($0 != nil) ? "not":""; log.verbose("HTTP response \(s) empty") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func getFromCacheIfAbleTo<Model>(from source: ServiceSource, key: Key?) -> Observable<Model?> where Model: Codable {
        guard
            let persisting = self as? Persisting,
            source.shouldLoadFromCache
            else {
                if !source.shouldLoadFromCache { log.debug("Prevented load from cache") }
                return .just(nil)
        }
        return persisting.asyncLoad(key: key)
            .do(onNext: { _ in log.verbose("Cache loading done") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
}

//MARK: - Private Methods
private extension Service {
    
    func getFromBackendAndCacheIfAbleTo<Model>(request: Router, from source: ServiceSource, key: Key?) -> Observable<Model> where Model: Codable {
        return getFromBackend(request: request, from: source)
            .retryOnConnect(options: source.retryWhenReachable, reachability: reachability)
            .catchError { self.handleErrorIfNeeded($0, from: source) }
            .flatMap { model in self.updateCacheIfAbleTo(with: model, from: source, key: key) }
            .filterNil()
            .filter(source.emitEventForValueFromBackend)
            .do(onNext: { _ in log.verbose("Got data") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func updateCacheIfAbleTo<Model>(with model: Model?, from source: ServiceSource, key: Key?) -> Observable<Model?> where Model: Codable {
        guard let persisting = self as? Persisting else { return .just(model) }
        guard !(model != nil && !source.shouldSaveToCache) else { if source.shouldFetchFromBackend { log.debug("Prevented save to cache") }; return .of(model!) }
        return persisting.asyncSaveOrDelete(model, key: key)
    }
    
    func handleErrorIfNeeded<Model>(_ error: Error, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        guard source.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("Suppressed http error: `\(error)`")
        return .empty()
    }
}

//MARK: - Convenience
public extension Service {
    
    var reachability: ReachabilityServiceConvertible { return httpClient.reachability }
    
    func get<Model>(modelType: Model.Type, request: Router, from source: ServiceSource, key: Key?) -> Observable<Model> where Model: Codable {
        return get(request: request, from: source, key: key) as Observable<Model>
    }
}

