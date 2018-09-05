## Easily write API services, cache models, and per request specify options

# What is this?
This is a protocol-driven RxSwift based convenience project for quick creation of services. You get everything for free conforming to this simple protocol:


```swift
protocol Service {
    var httpClient: HTTPClientProtocol { get }
}
```

# Usage

```swift
protocol CoinService: Service, Persisting {
    func getCoins(fromSource source: ServiceSource) -> Observable<[Coin]>
}

final class DefaultCoinService: CoinService {
    let httpClient: HTTPClientProtocol
    let cache: AsyncCache
}

extension DefaultCoinService {
   func getCoins() -> Observable<[Coin]> {
        return get(request: CoinRouter.all, from: .cacheAndBackend)
    }
}
```

The [CoinService.swift](Example/Source/Services/CoinService.swift) above conforms to `Service` which is all you need to get access to the methods `get`, `post` etc of a service. Have a look at the [`Example`](Example) app, fetching a list of cryptocurrencies which you can filter.

# Implementation

## Service

Actually, the protocol `Service` looks like this, but since all functions have default implementations, so the only thing you need to in order to conform to `Service` is to have `httpClient` property.

```swift
protocol Service {
    var httpClient: HTTPClientProtocol { get }

    // Methods that have default implementations, which you should not implement your self.
    func get<Model>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder, key: Key?) -> Observable<Model> where Model: Codable
    
    func post<Model>(request: Router, jsonDecoder: JSONDecoder) -> Observable<Model> where Model: Codable
    func postFireForget(request: Router) -> Observable<Void>
    
    // These should preferrably be `private`, however "overridden" by ImageService
    func getFromBackend<Model>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder) -> Observable<Model?> where Model: Codable
    func getFromCacheIfAbleTo<Model>(from source: ServiceSource, key: Key?) -> Observable<Model?> where Model: Codable
}
```

`CachingService` comes with a default HTTPClient, which you can use in your types, so you don't have to do anything really.

### ServiceSource - Options
 Where you can specify `ServiceSource`, which is an `enum` with three cases:
```swift
public enum ServiceSource {
    case cacheAndBackendOptions(ServiceOptionsInfo)
    case cache
    case backendOptions(ServiceOptionsInfo)
}
```

where `ServiceOptionsInfo` being a typealias for `[ServiceOptionsInfoItem]`:

```swift
public enum ServiceOptionsInfoItem {
    case emitValue
    case emitError
    case shouldCache
    case ifCachedPreventDownload
    case retryWhenReachable(ServiceRetry)
}
```

Using this you can easily specify if you request should fetch data from the:
1.  Cache only
2.  Backend only
3.  Cache and backend
    - Only fetch from backend if the cache was empty
    - Skip updating cache if value existed and got new from backend

For all requests towards your backend you can specify the retry policy for failing request:
```swift
public enum ServiceRetry {
    case count(Int) // TODO: Should be able to specify paus period between retries
    case forever // TODO: Should be using exponential backoff
    case timeout(TimeInterval)
}
```

## RxSwift - Nothing but Observables
`CachingService` relies heavily on RxSwift.


The heart of the project lies in the method `getFromBackendAndCacheIfAbleTo` below:

```swift
    func getFromBackendAndCacheIfAbleTo<Model>(request: Router, from source: ServiceSource, jsonDecoder: JSONDecoder, key: Key?) -> Observable<Model> where Model: Codable {
        return getFromBackend(request: request, from: source, jsonDecoder: jsonDecoder)
            .retryOnConnect(options: source.retryWhenReachable, reachability: reachability)
            .catchError { self.handleErrorIfNeeded($0, from: source) }
            .flatMap { model in self.updateCacheIfAbleTo(with: model, from: source, key: key) }
            .filterNil()
            .filter(source.emitEventForValueFromBackend)
    }
```



## Persisting
Optionally you can mark your service with the conformance to the `Persisting` protocol:

```swift
protocol Persisting {
    var cache: AsyncCache { get }

    // Has default implementation
    func getModels<Model>(using filter: FilterConvertible) -> Observable<[Model]> where Model: Codable & Filterable
}
```

Once again, the `getModels` already has a default implementation, so really you just need the `cache: AsyncCache` property.

### AsyncCache

The `AsyncCache` protocol looks like this:
```swift
protocol AsyncCache: Cache {
    func asyncSave<Value>(value: Value, for key: Key, done: Done<Void>?) where Value: Codable
    func asyncDelete(for key: Key, done: Done<Void>?)
    func asyncDeleteAll(done: Done<Void>?)
    
    func asyncLoadValue<Value>(for key: Key, done: Done<Value?>?) where Value: Codable
    func asyncHasValue<Value>(ofType type: Value.Type, for key: Key, done: Done<Bool>?) where Value: Codable
}
```

`CachingService` comes with a default implementation of said protocol, conformed to by the type `Storage` of the project [`Cache`](https://github.com/hyperoslo/Cache)(Pod/Carthage support exists).
