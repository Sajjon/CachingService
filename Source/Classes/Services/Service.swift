//
//  Service.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import Alamofire
import Reachability
import RxCocoa
import RxSwift
import RxOptional
import Cache
import SwiftyBeaver

public typealias Persistable = Codable & Identifiable

public protocol Identifiable {
    var id: String { get }
}
extension Identifiable where Self: Hashable {
    public var id: String {
        return String(describing: hashValue)
    }
}

public protocol OrderedListOfUniquePersistables: AnyObject, Codable {
    associatedtype Element: Persistable
    var elements: [Element] { get set }
    static var persistanceKey: String { get }
    init(_ elements: [Element])
    func update(element: Element) -> [Element]
}

public extension OrderedListOfUniquePersistables {

    public static var persistanceKey: String {
        return "\(type(of: Element.self))List"
    }

    public func update(element: Element) -> [Element] {
        if let index = elements.index(where: { $0.id == element.id}) {
            elements[index] = element
        } else {
            elements.append(element)
        }
        return elements
    }
}

public protocol Service {
    var httpClient: HTTPClientProtocol { get }
    
    func get<Model>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder) -> Observable<Model> where Model: Codable

    typealias ModelFromBackendTransform<M: Codable, P: OrderedListOfUniquePersistables> = (M) -> P
    func getList<PersistedList, ModelFromBackend>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder, type: PersistedList.Type, modelFromBackendTransform: @escaping ModelFromBackendTransform<ModelFromBackend, PersistedList>) -> Observable<[PersistedList.Element]> where PersistedList: OrderedListOfUniquePersistables, ModelFromBackend: Codable

    func post<Model>(request: Router, jsonDecoder: JSONDecoder) -> Observable<Model> where Model: Codable
    func put(request: Router) -> Observable<Void>
    func postFireForget(request: Router) -> Observable<Void>
    
//    func getFromBackend<Model>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder) -> Observable<Model> where Model: Codable
//    func getFromBackend<PersistedList>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder, type: PersistedList.Type) -> Observable<[PersistedList.Element]> where PersistedList: OrderedListOfUniquePersistables
    func getFromBackend<ModelFromBackend>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder) -> Observable<ModelFromBackend> where ModelFromBackend: Codable

//    func getFromCacheIfAbleTo<Model>(from source: ServiceSource, key: Key) -> Observable<Model> where Model: Codable
    func getFromCacheIfAbleTo<PersistedList>(from source: ServiceSource) -> Observable<PersistedList> where PersistedList: OrderedListOfUniquePersistables
}

public extension Service {
    var reachability: ReachabilityServiceConvertible { return httpClient.reachability }
}

//MARK: - Default Implementation
public extension Service {
    
    func getList<PersistedList>(request: Router, from source: ServiceSource = .default, jsonDecoder: JSONDecoder = JSONDecoder(), type: PersistedList.Type) -> Observable<[PersistedList.Element]> where PersistedList: OrderedListOfUniquePersistables {
        return getList(request: request, from: source, jsonDecoder: jsonDecoder, type: type) { (modelFromBackend: PersistedList) in modelFromBackend }
    }

    func getList<PersistedList, ModelFromBackend>(
            request: Router,
            from source: ServiceSource = .default,
            jsonDecoder: JSONDecoder = JSONDecoder(),
            type: PersistedList.Type,
            modelFromBackendTransform: @escaping ModelFromBackendTransform<ModelFromBackend, PersistedList>
        ) -> Observable<[PersistedList.Element]> where PersistedList: OrderedListOfUniquePersistables, ModelFromBackend: Codable {

        let list: Observable<PersistedList> = getFromCacheIfAbleTo(from: source)
        return list.flatMapLatest { (list: PersistedList) -> Observable<[PersistedList.Element]> in
                if source.ifCachedPreventDownload {
                    return .just(list.elements)
                } else {
                    let fromBackend: Observable<PersistedList> = self.getFromBackendAndCacheIfAbleTo(request: request, from: source, jsonDecoder: jsonDecoder, type: type, modelFromBackendTransform: modelFromBackendTransform)
                    let cacheAndBackend: Observable<PersistedList> = Observable.from(optional: list).concat(fromBackend)
                    return cacheAndBackend.map {
                        $0.elements
                    }
                }
        }
    }
   
//    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model> where Model: Codable {
//        return getFromBackend(request: request, from: source, jsonDecoder: JSONDecoder())
//    }

    func getFromBackend<ModelFromBackend>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder) -> Observable<ModelFromBackend> where ModelFromBackend: Codable {
        guard source.shouldFetchFromBackend else { log.debug("Prevented fetch from backend"); return .empty() }
        return httpClient.makeRequest(request: request, jsonDecoder: jsonDecoder)
//            .do(onNext: { let s: String = ($0 != nil) ? "not" : ""; log.verbose("HTTP response \(s) empty") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func getFromCacheIfAbleTo<PersistedList>(from source: ServiceSource) -> Observable<PersistedList> where PersistedList: OrderedListOfUniquePersistables {
        guard
            let persisting = self as? Persisting,
            source.shouldLoadFromCache
            else {
                if !source.shouldLoadFromCache { log.debug("Prevented load from cache") }
                return .empty()
        }
        return persisting.asyncLoad(key: PersistedList.persistanceKey).filterNil()
//            .do(onNext: { _ in log.verbose("Cache loading done") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
}

//MARK: - POST
public extension Service {
    func post<Model>(request: Router, jsonDecoder: JSONDecoder = JSONDecoder()) -> Observable<Model> where Model: Codable {
        return httpClient.makeRequest(request: request, jsonDecoder: jsonDecoder)
    }

    func postFireForget(request: Router) -> Observable<Void> {
        return httpClient.makeFireForgetRequest(request: request)
    }
}

//MARK: - PUT
public extension Service {
    func put(request: Router) -> Observable<Void> {
        precondition(request.method == .put)
        return postFireForget(request: request)
    }
}

//MARK: - Private Methods
private extension Service {
    
    func getFromBackendAndCacheIfAbleTo<PersistedList, ModelFromBackend>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder, type: PersistedList.Type, modelFromBackendTransform: @escaping ModelFromBackendTransform<ModelFromBackend, PersistedList>) -> Observable<PersistedList> where PersistedList: OrderedListOfUniquePersistables, ModelFromBackend: Codable {
        let fromBackend: Observable<ModelFromBackend> = getFromBackend(request: request, from: source, jsonDecoder: jsonDecoder)
        let mappedFromBackend: Observable<PersistedList> = fromBackend.map { modelFromBackendTransform($0) }
        return mappedFromBackend
            .retryOnConnect(options: source.retryWhenReachable, reachability: reachability)
            .catchError { self.handleErrorIfNeeded($0, from: source) }
            .flatMapLatest { list in self.updateCacheIfAbleTo(with: list, from: source) }
//            .filterNil()
            .filter(source.emitEventForValueFromBackend)
//            .do(onNext: { _ in log.verbose("Got data") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func updateCacheIfAbleTo<PersistedList>(with list: PersistedList, from source: ServiceSource) -> Observable<PersistedList> where PersistedList: OrderedListOfUniquePersistables {
        guard let persisting = self as? Persisting, source.shouldSaveToCache else {
//            defer { if source.shouldFetchFromBackend { log.debug("Prevented save to cache") } }
            return .just(list)
        }
        return persisting.asyncSaveOrDelete(list, key: PersistedList.persistanceKey).filterNil()
    }
    
    func handleErrorIfNeeded<Model>(_ error: Error, from source: ServiceSource) -> Observable<Model> where Model: Codable {
        guard source.catchErrorsFromBackend else { log.error("Emitting error: `\(error)`"); return .error(error) }
        log.verbose("Suppressed http error: `\(error)`")
        return .empty()
    }
}

//
////MARK: - Convenience
//public extension Service {
//    func get<Model>(request: Router, from source: ServiceSource = .default, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy, key: Key = nil) -> Observable<Model> where Model: Codable {
//        return get(request: request, from: source, jsonDecoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy), key: key)
//    }
//}
//
////MARK: ModelType as Argument
//public extension Service {
//
//    func get<Model>(modelType: Model.Type, request: Router, from source: ServiceSource = .default, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy, key: Key = nil) -> Observable<Model> where Model: Codable {
//        return get(request: request, from: source, jsonDecoder: JSONDecoder(dateDecodingStrategy: dateDecodingStrategy), key: key) as Observable<Model>
//    }
//
//    func get<Model>(modelType: Model.Type, request: Router, from source: ServiceSource = .default, jsonDecoder: JSONDecoder = JSONDecoder(), key: Key = nil) -> Observable<Model> where Model: Codable {
//        return get(request: request, from: source, jsonDecoder: jsonDecoder, key: key) as Observable<Model>
//    }
//
//    func post<Model>(modelType: Model.Type, request: Router, jsonDecoder: JSONDecoder = JSONDecoder()) -> Observable<Model> where Model: Codable {
//        return post(request: request, jsonDecoder: jsonDecoder) as Observable<Model>
//    }
//}
