//
//  HTTPHeaderStoreProtocol.swift
//  API
//
//  Created by Alexander Cyon on 2017-11-01.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation

public protocol HTTPHeaderStoreProtocol: class {
    
    var headers: [String: String] { set get }
    
    var proxies: [String: KeyValueStoreProxy] { set get }
    func addProxy<Proxy>(_ proxy: Proxy, named: String, keysMapping: [KeyMapping]) where Proxy: KeyValueStoreProtocol
    func removeProxy(named: String)
    
    func addHeader(_ value: String, for key: String)
    func removeHeader(for key: String)
    func header(for key: String) -> String?
    
    func injectHeaders(to request: inout URLRequest)
}

public extension HTTPHeaderStoreProtocol {
    
    /// ⚠️ The time complexity of this function is a joke.... O(p*|d|*|f|) where `p`=#proxies, `|d|`= number of key-value entries in said proxy, `|f|`= numbers of filters. However, as Donald Knuth so elegantly said "Premature optimization is the root of all evil", the number of proxies will probably be less than 3 and key-value pairs probably less than 20 and filter probably less than 10 so exection time will be negligible anyway.
    func extractHeadersFromProxies() -> [String: String] {
        var headersFromProxies = [String: String]()
        let proxyStores = proxies.values.map { $0.store }
        let proxyFilters = proxies.values.map { $0.filter }
        
        for i in 0..<proxies.count { // O(p)
            let proxyStore = proxyStores[i]
            let proxyFilters = proxyFilters[i]
            for (key, value) in proxyStore.dictionaryRepresentation { // O(|d|), |d| = number of key-value entries
                guard value is String, let stringValue = value as? String else { continue }
                for mappingFilter in proxyFilters { // O(|f|), |f| = proxyFilters.count, make sure we do not add a Key-Value pair without explicit right (via `filter`)
                    guard mappingFilter.from == key else { continue }
                    headersFromProxies[mappingFilter.to] = stringValue
                }
            }
        }
        return headersFromProxies
    }
    
    func extractHeadersIncludingProxies() -> [String: String] {
        return headers.merging(extractHeadersFromProxies()) { (current, _) in current }
    }
    
    func addProxy<Proxy>(_ proxy: Proxy, named: String, keysMapping: [KeyMapping]) where Proxy: KeyValueStoreProtocol {
        guard !keysMapping.isEmpty else { log.warning("Ignoring try to add KeyValueStore named `\(named)` since you specified an empty keys array"); return }
        proxies[named] = KeyValueStoreProxy(name: named, store: AnyKeyValueStore(proxy), filter: keysMapping)
    }
    
    func removeProxy(named: String) {
        proxies.removeValue(forKey: named)
    }
    
    func injectHeaders(to request: inout URLRequest) {
        let headersToInject = extractHeadersIncludingProxies()
        for (key, value) in headersToInject {
            log.verbose("💉 Injecting header=`\(key)` with value=`\(value)`")
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    func addHeader(_ value: String, for key: String) {
        headers[key] = value
    }
    
    func removeHeader(for key: String) {
        headers.removeValue(forKey: key)
    }
    
    func header(for key: String) -> String? {
        return headers[key]
    }
}

public extension HTTPHeaderStoreProtocol {
    
    func addProxy<Proxy>(_ proxy: Proxy, named: String, includeKeys filter: [String]) where Proxy: KeyValueStoreProtocol {
        addProxy(proxy, named: named, keysMapping: filter.map { KeyMapping(from: $0, to: $0) })
    }
    
    func addKeyedProxy<KeyedProxy>(_ proxy: KeyedProxy, named: String, includeKeys filter: [KeyedProxy.Key]) where KeyedProxy: KeyedKeyValueStoreProtocol {
        addProxy(proxy, named: named, keysMapping: filter.map({ $0.identifier }).map { KeyMapping(from: $0, to: $0) })
    }
    
    func addKeyedProxy<KeyedProxy>(_ proxy: KeyedProxy, named: String, keysMapping: () -> [(from: KeyedProxy.Key, to: String)]) where KeyedProxy: KeyedKeyValueStoreProtocol {
        let filter = keysMapping()
        let mappings = filter.map { KeyMapping(from: $0.from.identifier, to: $0.to) }
        addProxy(proxy, named: named, keysMapping: mappings)
    }
}

public final class HTTPHeaderStore: HTTPHeaderStoreProtocol {
    public var proxies = [String: KeyValueStoreProxy]()
    
    public var headers = [String: String]()
    public init(headers: [String: String] = [:]) {
        self.headers = headers
    }
}

