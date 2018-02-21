//
//  ImageService.swift
//  Example
//
//  Created by Alexander Cyon on 2018-01-23.
//  Copyright © 2018 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import CachingService

final class ImageService: ImageServiceProtocol {
    
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
    
    init(
        httpClient: HTTPClientProtocol,
        cache: AsyncCache) {
        self.httpClient = httpClient
        self.cache = cache
    }
}
