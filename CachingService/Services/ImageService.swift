//
//  ImageService.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import Kingfisher

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif 

protocol ImageService {
    var reachabilityService: ReachabilityServiceConvertible { get }
    func imageFromURL(_ url: URL) -> Observable<DownloadableImage>
}

extension ImageService {
    
    func imageFromURL(_ url: URL?) -> Observable<DownloadableImage> {
        guard let url = url else { return .empty() }
        return imageFromURL(url)
    }
}


typealias RetrievedImage = (Image?, CacheType) -> Void

extension URL: Key {
    var identifier: String { return absoluteString }
}

extension ImageCache {
    func retrieveImage(for key: Key, options: KingfisherOptionsInfo? = nil, retrieved: RetrievedImage?) {
        self.retrieveImage(forKey: key.identifier, options: options, completionHandler: retrieved)
    }
}

extension ImageCache {
    func retrieveImage(for key: Key, options: KingfisherOptionsInfo? = nil) -> Observable<Image> {
        return Observable.create { observer in
            
            self.retrieveImage(for: key, options: options) { maybeImage, cacheType in
                defer { observer.onCompleted() }
                guard let image = maybeImage else { return }
                observer.onNext(image)
            }
            
            return Disposables.create()
        }
    }
}

final class DefaultImageService: ImageService {
    

    // 1st level cache
    private let _inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    // 2nd level cache
    private let persistentCache = NSCache<AnyObject, AnyObject>()
    private let kingfisherImageCache = ImageCache.default
    
    let activityIndicator = ActivityIndicator()
    
    let reachabilityService: ReachabilityServiceConvertible
    private let urlSession: URLSession
    private let backgroundWorkScheduler: ImmediateSchedulerType
    private let mainScheduler: SerialDispatchQueueScheduler
    
    init(
        reachabilityService: ReachabilityServiceConvertible,
        urlSession: URLSession,
        backgroundWorkScheduler: ImmediateSchedulerType,
        mainScheduler: SerialDispatchQueueScheduler
        ) {
        self.reachabilityService = reachabilityService
        self.urlSession = urlSession
        self.backgroundWorkScheduler = backgroundWorkScheduler
        self.mainScheduler = mainScheduler
        
        // cost is approx memory usage
//        persistentCache.totalCostLimit = 10 * MB
//        inMemoryCache.countLimit = 20
    }
    
    private func decodeImage(_ imageData: Data) -> Observable<Image> {
        return Observable.just(imageData)
            .observeOn(backgroundWorkScheduler)
            .map { data in
                guard let image = Image(data: data) else {
                    // some error
                    throw ServiceError.api(.httpGeneric)
                }
                return image.forceLazyImageDecompression()
        }
    }
    
    private func _imageFromURL(_ url: URL) -> Observable<Image> {
        return kingfisherImageCache.retrieveImage(for: url)
//        return Observable.deferred {
//            let maybeImage = self.inMemoryCache.object(forKey: url as AnyObject) as? Image
////            kingfisherImageCache.retrieveImage(forKey: url.absoluteString, options: nil, completionHandler: <#T##((Image?, CacheType) -> ())?##((Image?, CacheType) -> ())?##(Image?, CacheType) -> ()#>)
//
//            let decodedImage: Observable<Image>
//
//            // best case scenario, it's already decoded an in memory
//            if let image = maybeImage {
//                decodedImage = Observable.just(image)
//            }
//            else {
//                let cachedData = self.persistentCache.object(forKey: url as AnyObject) as? Data
//
//                // does image data cache contain anything
//                if let cachedData = cachedData {
//                    decodedImage = self.decodeImage(cachedData)
//                }
//                else {
//                    // fetch from network
//                    decodedImage = self.urlSession.rx.data(request: URLRequest(url: url))
//                        .do(onNext: { data in
//                            self.persistentCache.setObject(data as AnyObject, forKey: url as AnyObject)
//                        })
//                        .flatMap(self.decodeImage)
//                        .trackActivity(self.activityIndicator)
//                }
//            }
//
//            return decodedImage.do(onNext: { image in
//                self.inMemoryCache.setObject(image, forKey: url as AnyObject)
//            })
//        }
    }
    
    /**
     Service that tries to download image from URL.
     
     In case there were some problems with network connectivity and image wasn't downloaded, automatic retry will be fired when networks becomes
     available.
     
     After image is successfully downloaded, sequence is completed.
     */
    func imageFromURL(_ url: URL) -> Observable<DownloadableImage> {
        return _imageFromURL(url)
            .map { DownloadableImage.content(image: $0) }
//            .retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: reachabilityService)
            .startWith(.content(image: Image()))
    }
}
