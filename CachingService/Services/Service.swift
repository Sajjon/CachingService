//
//  Service.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional
import Alamofire

protocol Service {
    var reachability: ReachabilityService { get }
    var httpClient: HTTPClientProtocol { get }
    func get<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable
}

//MARK: - Default Implementation
extension Service {
    func get<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        return getFromCacheIfAbleTo(from: source).concat(
            getFromBackendAndCacheIfAbleTo(request: request, from: source)
        )
    }
}

//MARK: - Private Methods
private extension Service {
    
    func getFromBackendAndCacheIfAbleTo<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        return getFromBackend(request: request, from: source)
            .catchError { self.handleErrorIfNeeded($0, from: source) }
            .flatMap { model in self.updateCacheIfAbleTo(with: model, from: source) }
            .filterNil()
            .filter(source.emitEventForValueFromBackend)
            .do(onNext: { log.verbose("Got: \($0)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model?> where Model: Codable {
        guard source.shouldServiceSourceBackend else { log.debug("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest(request: request)
            .do(onNext: { var s = "empty"; if let d = $0 { s = "\(d)" }; log.verbose("HTTP response: \(s)") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func updateCacheIfAbleTo<Model>(with model: Model?, from source: ServiceSource) -> Observable<Model?> where Model: Codable {
        guard let persisting = self as? Persisting else { return .just(model) }
        guard !(model != nil && !source.shouldSaveToCache) else { log.debug("Prevented save to cache"); return .of(model!) }
        return persisting.asyncSaveOrDelete(model, key: KeyCreator<Model>.key)
        
    }
    
    func getFromCacheIfAbleTo<Model>(from source: ServiceSource) -> Observable<Model> where Model: Codable {
        guard let persisting = self as? Persisting else { return .empty() }
        guard source.shouldLoadFromCache else { log.debug("Prevented load from cache"); return .empty() }
        return persisting.asyncLoad()
            .filterNil()
    }
    
    func handleErrorIfNeeded<Model>(_ error: Error, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        guard source.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("Suppressed http error: `\(error)`")
        return .empty()
    }
}

