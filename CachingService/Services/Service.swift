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

//protocol MyImageService: Service {
//    func getImage(urlString: String, from source: ServiceSource) -> Observable<UIImage>
//}
//
//extension MyImageService {
//    func getImage(urlString: String, from source: ServiceSource) -> Observable<UIImage> {
//        return get(request: urlString as Router, from: source)
//    }
//}

protocol Service {
    var httpClient: HTTPClientProtocol { get }
    func get<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable
}

extension Service {
    var reachability: ReachabilityService { return httpClient.reachability }
}

//MARK: - Default Implementation
extension Service {
    func get<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        return getFromCacheIfAbleTo(from: source).concat(
            getFromBackendAndCacheIfAbleTo(request: request, from: source)
        )
    }
}


//extension ObservableConvertibleType {
//    func retryOnBecomesReachable(reachabilityService: ReachabilityService) -> Observable<E> {
//        return self.asObservable()
//            .catchError {
//                guard
//                    let apiError = $0 as? ServiceError.APIError,
//                    apiError == .noNetwork
//                else { return .error($0) }
//                return Observable.empty()
//        }
//    }
//}

//extension ObservableConvertibleType {
//    func retryOnBecomesReachable(_ valueOnFailure: E? = nil, reachabilityService: ReachabilityService) -> Observable<E> {
//        return self.asObservable()
//            .catchError { (e) -> Observable<E> in
//                reachabilityService.reachability
//                    //                    .skip(1)
//                    .filter { $0.reachable }
//                    .flatMap { (reachable: ReachabilityStatus) -> Observable<E> in
//                        log.warning("reachable: `\(reachable)`")
//                        return Observable<E>.error(e)
//                }
////                    .startWith(valueOnFailure).filterNil()
//            }
//            .retry()
////            .do(onNext: { log.debug("onNext `\($0)`") }, onError: { log.debug("onError: \($0)") })
//    }
//}

extension ObservableConvertibleType {
    func retryOnBecomesReachable(_ valueOnFailure: E? = nil, options: ServiceRetry?, reachabilityService: ReachabilityService) -> Observable<E> {
        guard let options = options else { log.error("NO RETRY OPTIONS!!!!!");return self.asObservable() }
        return self.asObservable()
            .catchError { error in
                guard error == ServiceError.api(.noNetwork) else { return .error(error) }
                return reachabilityService.reachability
                    .skip(1)
                    .filter {
                        guard $0.reachable else { log.warning("Filter: NOT REACHABLE"); return false }
                        log.warning("Filter: REACHABLE :D"); return true
                    } // dont want to know when we lose connection
                    .flatMap { (reachable: ReachabilityStatus) -> Observable<E> in
                        log.warning("RETURNING EMPTY FROM FLATMAP")
                     return Observable<E>.empty()
                }
            }.retry(options: options)
    }
    
    func retry(options: ServiceRetry) -> Observable<E> {
        switch options {
        case .forever:
             log.warning("forever")
            return self.asObservable().retry()
        case .count(let count):
            log.warning("count")
            return self.asObservable().retry(count)
        }
    }
}

//MARK: - Private Methods
private extension Service {
    
    func getFromBackendAndCacheIfAbleTo<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        return getFromBackend(request: request, from: source)
            .retryOnBecomesReachable(options: source.retryWhenReachable, reachabilityService: reachability)
            .catchError { self.handleErrorIfNeeded($0, from: source) }
            .flatMap { model in self.updateCacheIfAbleTo(with: model, from: source) }
            .filterNil()
            .filter(source.emitEventForValueFromBackend)
            .do(onNext: { _ in log.verbose("Got data") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model?> where Model: Codable {
        guard source.shouldFetchFromBackend else { log.debug("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest(request: request)
            .do(onNext: { let s: String = ($0 != nil) ? "not":""; log.verbose("HTTP response \(s) empty") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
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
               .do(onNext: { _ in log.verbose("Cache loading done") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func handleErrorIfNeeded<Model>(_ error: Error, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        guard source.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("Suppressed http error: `\(error)`")
        return .empty()
    }
    
//    func handleUnreachableErrorIfNeeded<Model>(_ error: Error, from source: ServiceSource) -> Observable<Model> where Model: Codable {
//        guard let retryOptions = source.retryWhenReachable else { return .error(error) }
////        guard source.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
//        log.verbose("Suppressed http error: `\(error)`")
//        return .empty()
//    }
}

//extension ObservableConvertibleType {
//    func silenceError(_ shouldSilenceError: @escaping (Error) -> Bool) -> Observable<E> {
//        return asObservable().catchError { error in
//            guard shouldSilenceError(error) else { return .error(error) }
//            return .empty()
//        }
//    }
//}

