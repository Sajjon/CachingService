//
//  Coin.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

struct Coin: Codable {
    let coinId: String
    let name: String
    let symbol: String
    let imageUrlStringSuffix: String?
    enum CodingKeys: String, CodingKey {
        case coinId = "Id"
        case imageUrlStringSuffix = "ImageUrl"
        case name = "Name"
        case symbol = "Symbol"
    }
}

extension Coin {
    var imageUrlStringPrefix: String { return "https://www.cryptocompare.com" }
    var imageUrlString: String? {
        guard let suffix = imageUrlStringSuffix else { return nil }
        return imageUrlStringPrefix + suffix
        
    }
    var imageUrl: URL? {
        guard let urlString = imageUrlString else { return nil }
        return URL(string: urlString)
        
    }
}

extension Coin: Equatable {
    public static func ==(rhs: Coin, lhs: Coin) -> Bool {
        return rhs.coinId == lhs.coinId
    }
}

//MARK: - StaticKeyConvertible
extension Coin: StaticKeyConvertible {
    static var key: Key { return "coinId" }
}

//MARK: - Filterable
extension Coin: Filterable {
    static var primaryKeyPath: AnyKeyPath? { return \Coin.coinId }
    static var keyPaths: [AnyKeyPath] { return stringPaths.map { $0 } }
}

extension Coin {
    static var stringPaths: [KeyPath<Coin, String>] {
        return [\.name, \.symbol]
    }
}

