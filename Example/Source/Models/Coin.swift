//
//  Coin.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-02.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import CachingService

typealias Amount = Double

public struct Price: Codable {
    let btc: Amount
    let usd: Amount
}

extension Coin: Identifiable {
    public var id: String {
        return coinId
    }
}

public struct Coin: Codable {
    let coinId: String
    let symbol: String
    let name: String
    let imageUrlStringSuffix: String?
    let totalSupply: Int?
    let price: Price?
    
    enum CodingKeys: String, CodingKey {
        case coinId = "Id"
        case imageUrlStringSuffix = "ImageUrl"
        case name = "CoinName"
        case symbol = "Symbol"
        case totalSupply = "TotalCoinSupply"
        case price
    }
    public init(id: String, symbol: String, name: String, totalSupply: Int?, urlString: String?, price: Price? = nil) {
        self.coinId = id
        self.symbol = symbol
        self.name = name
        self.imageUrlStringSuffix = urlString
        self.totalSupply = totalSupply
        self.price = price
    }

    init(coin: Coin, price: Price) {
        self.init(id: coin.coinId, symbol: coin.symbol, name: coin.name, totalSupply: coin.totalSupply, urlString: coin.imageUrlStringSuffix, price: price)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        coinId = try values.decode(String.self, forKey: .coinId)
        symbol = try values.decode(String.self, forKey: .symbol)
        name = try values.decode(String.self, forKey: .name)
        imageUrlStringSuffix = try values.decodeIfPresent(String.self, forKey: .imageUrlStringSuffix)
        if let _totalSupply: String = try values.decodeIfPresent(String.self, forKey: .totalSupply) {
            totalSupply = Int(_totalSupply)
        } else { totalSupply = nil }
        price = try values.decodeIfPresent(Price.self, forKey: .price)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coinId, forKey: .coinId)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(totalSupplyString, forKey: .totalSupply)
        try container.encodeIfPresent(imageUrlStringSuffix, forKey: .imageUrlStringSuffix)
        try container.encodeIfPresent(price, forKey: .price)
    }

    func adding(price: Price) -> Coin {
        return Coin(coin: self, price: price)
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
    
    var totalSupplyString: String { guard let supply = totalSupply else { return "" }; return "\(supply)" }
    
}

extension Coin: Equatable {
    public static func ==(rhs: Coin, lhs: Coin) -> Bool {
        return rhs.coinId == lhs.coinId
    }
}

////MARK: - StaticKeyConvertible
//extension Coin: StaticKeyConvertible {
//    public static var key: Key { return "coinId" }
//}

//MARK: - Filterable
extension Coin: Filterable {
    public static var primaryKeyPath: AnyKeyPath? { return \Coin.coinId }
    public static var keyPaths: [AnyKeyPath] { return stringPaths.map { $0 } }
}

extension Coin {
    static var stringPaths: [KeyPath<Coin, String>] {
        return [\.name, \.symbol]
    }
}

