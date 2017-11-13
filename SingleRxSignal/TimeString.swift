//
//  TimeString.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-10.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

extension Date {
    static var timeAsString: String { return Date().timeString }
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: self)
    }
}
