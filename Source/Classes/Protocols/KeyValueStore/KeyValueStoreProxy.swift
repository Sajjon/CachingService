//
//  KeyValueStoreProxy.swift
//  CachingService
//
//  Created by Alexander Cyon on 2018-02-22.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation

public struct KeyValueStoreProxy {
    let name: String
    let store: AnyKeyValueStore
    let filter: [KeyMapping]
}
