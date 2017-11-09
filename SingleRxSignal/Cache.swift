//
//  Cache.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxOptional

let cacheKeyName = "name"
extension UserDefaults: Cache {
    
    func load<C>() -> C? where C: NameOwner {
        guard let name = string(forKey: cacheKeyName) else { return nil }
        return C.init(name: name)
    }
    
    func save<C>(_ data: C) throws where C: NameOwner {
        self.set(data.name, forKey: cacheKeyName)
    }
    
    func deleteValueFor(key: String) {
        self.removeObject(forKey: key)
    }

    func hasValueForKey(key: String) -> Bool {
        return self.object(forKey: key) != nil
    }
}

protocol Cache {
    func load<C>() -> C? where C: NameOwner
    func save<C>(_ data: C) throws where C: NameOwner
    func deleteValueFor(key: String)
    func hasValueForKey(key: String) -> Bool
}

protocol Persisting {
    var cache: Cache { get }
}

extension Persisting {
    func load<C>() -> Observable<C> where C: NameOwner {
        return Observable.of(cache.load()).errorOnNil().do(onNext: { print("Found in cache: `\($0)`") })
    }
}
