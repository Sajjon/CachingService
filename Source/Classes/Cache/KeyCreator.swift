//
//  KeyCreator.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct KeyCreator<T> {
    static var key: Key {
        return "\(FourLevelTypeUnwrapper<T>.fourLevelUnwrappedType)"
    }
}

protocol OptionalType {
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalType {
    static var wrappedType: Any.Type { return Wrapped.self }
}

struct FourLevelTypeUnwrapper<T> {
    static var fourLevelUnwrappedType: Any.Type {
        guard let optionalTypeLevel1 = T.self as? OptionalType.Type else { return T.self }
        guard let optionalTypeLevel2 = optionalTypeLevel1.wrappedType as? OptionalType.Type else { return optionalTypeLevel1.wrappedType }
        guard let optionalTypeLevel3 = optionalTypeLevel2.wrappedType as? OptionalType.Type else { return optionalTypeLevel2.wrappedType }
        guard let optionalTypeLevel4 = optionalTypeLevel3.wrappedType as? OptionalType.Type else { return optionalTypeLevel3.wrappedType }
        return optionalTypeLevel4.wrappedType
    }
}
