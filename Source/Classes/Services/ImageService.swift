//
//  ImageService.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-18.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift
import Cache

public typealias Image = UIImage

extension ImageWrapper: Hashable & Identifiable {
    public var hashValue: Int {
        return self.image.hashValue
    }

    public static func == (lhs: ImageWrapper, rhs: ImageWrapper) -> Bool {
        return lhs.image == rhs.image
    }
}

public final class ImageList: OrderedListOfUniquePersistables {
    public var elements: [ImageWrapper]
    public init(_ images: [ImageWrapper]) {
        self.elements = images
    }
}

public protocol ImageServiceProtocol: Service, Persisting {
    func imageFromURL(_ url: URL) -> Observable<Image>
    func deleteAllImages() -> Observable<Void>
}

public extension ImageServiceProtocol {
    func imageFromURL(_ url: URL) -> Observable<Image> {
        let source: ServiceSource = .cacheAndBackendOptions(ServiceOptionsInfo.default.inserting(.ifCachedPreventDownload))
//        return self.get(modelType: ImageWrapper.self, request: url, from: source, key: url).map { $0.image }
        return getList(request: url, from: source, type: ImageList.self) { (modelFromBackend: ImageWrapper) -> ImageList in
            return ImageList([modelFromBackend])
            }.map {
                $0.first!.image
        }
    }
    
    func getFromBackend<Model>(request: Router, from source: ServiceSource) -> Observable<Model?> where Model: Codable {
        guard source.shouldFetchFromBackend else { log.debug("Prevented fetch from backend"); return .empty() }
        let image: Observable<UIImage> = httpClient.download(request: request)
        return image.map { ImageWrapper(image: $0) as? Model }
    }
    
    func getFromCacheIfAbleTo<Model>(from source: ServiceSource, key: Key?) -> Observable<Model?> where Model: Codable {
        guard source.shouldLoadFromCache else { log.debug("Prevented load from cache"); return .just(nil) }
        return asyncLoad(key: key)
            .do(onNext: { _ in log.verbose("Cache loading done") }, onError: { log.error("error: \($0)") }, onCompleted: { log.verbose("onCompleted") })
    }
    
    func deleteAllImages() -> Observable<Void> {
        log.debug("Deleting all images")
        return asyncDeleteAll()
    }
}

public extension ImageServiceProtocol {
    func imageFromURL(_ url: URL?) -> Observable<Image> {
        guard let url = url else { return .empty() }
        return imageFromURL(url)
    }
}

