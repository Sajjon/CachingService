//
//  AuthTokensConvertible.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-10-31.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation

protocol AuthTokensConvertible: Codable {
    var accessToken: String { get }
    var refreshToken: String { get }
}
