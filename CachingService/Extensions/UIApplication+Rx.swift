//
//  UIApplication+Rx.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-12-11.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIApplication {
    
    /// Bindable sink for `networkActivityIndicatorVisible`.
    public var isNetworkActivityIndicatorVisible: Binder<Bool> {
        return Binder(self.base) { application, active in
            application.isNetworkActivityIndicatorVisible = active
        }
    }
}
