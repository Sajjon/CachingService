//
//  Persisting.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxOptional

protocol Persisting {
    var cache: AsyncCache { get }
    func getModels<Model>(using filter: FilterConvertible) -> Observable<[Model]> where Model: Codable & Filterable
}

extension Persisting {
    func getModels<Model>(using filter: FilterConvertible) -> Observable<[Model]> where Model: Codable & Filterable {
        return asyncLoad()
            .filterNil()
            .filterValues(using: filter)
    }
    
    func getModels<Model>(ofType type: Model.Type, using filter: FilterConvertible) -> Observable<[Model]> where Model: Codable & Filterable {
        return getModels(using: filter) as Observable<[Model]>
    }
}


extension Persisting {
    func asyncLoad<C>(for key: Key) -> Observable<C?> where C: Codable {
        return Observable.create { observer in
            self.cache.asyncLoadValue(for: key) { (result: CacheResult<C?>) in
                switch result {
                case .success(let loadedFromCache):
                    observer.onNext(loadedFromCache)
                    observer.onCompleted()
                case .error(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
            }
            .do(onNext: { guard $0 != nil else { log.verbose("Cache empty"); return }; log.verbose("Found data in cache :D") })
    }
    
    func asyncSaveOrDelete<C>(_ optional: C?, key: Key?) -> Observable<C?> where C: Codable {
        return Observable.create { observer in
            self.cache.asyncSaveOrDelete(optional: optional, for: key) { savingResult in
                switch savingResult {
                case .success:
                    if let _ = optional {
                        log.verbose("Successfullt cached data")
                    } else {
                        log.verbose("Wrote nil to cache")
                    }
                    observer.onNext(optional)
                    observer.onCompleted()
                case .error(let error):
                    log.error("Failed to cache error - `\(error)`")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
   
    func asyncDeleteAll() -> Observable<Void> {
        return Observable.create { observer in
            self.cache.asyncDeleteAll() { _ in
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func asyncDeleteValue<C>(forType type: C.Type) -> Observable<C?> where C: Codable {
        let optional: C? = nil
        return asyncSaveOrDelete(optional, key: KeyCreator<C>.key)
    }
}

extension Persisting {
    func asyncLoad<C>(key: Key? = nil) -> Observable<C?> where C: Codable {
        let key = key ?? KeyCreator<C>.key
        return asyncLoad(for: key)
    }
    
    func asyncSave<C>(_ optional: C?, key: Key? = nil) -> Observable<C?> where C: Codable {
        let key = key ?? KeyCreator<C>.key
        return asyncSaveOrDelete(optional, key: key)
    }
}
