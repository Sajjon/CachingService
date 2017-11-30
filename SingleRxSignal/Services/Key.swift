//
//  Key.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

protocol Key {
    var identifier: String { get }
}

extension String: Key {
    var identifier: String {
        return self
    }
}
