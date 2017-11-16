//
//  AbstractViewController+Retaining.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-16.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import ObjectiveC

// Declare a global var to produce a unique address as the assoc object handle
var associatedObjectHandle: UInt8 = 0
extension UIViewController {
    var abstract: AbstractViewController {
        get {
            return objc_getAssociatedObject(self, &associatedObjectHandle) as! AbstractViewController
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
