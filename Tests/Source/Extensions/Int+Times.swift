//
//  Int+Times.swift
//  CachingServiceTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

// stolen from: https://stackoverflow.com/a/30554255/1311272
extension Int {
    
    func timesCounting(_ f: (Int) -> ()) {
        if self > 0 {
            for i in 0..<self {
                f(i)
            }
        }
    }
    
    func times(_ f: () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
    
    func times(f: @autoclosure () -> ()) {
        if self > 0 {
            for _ in 0..<self {
                f()
            }
        }
    }
}
