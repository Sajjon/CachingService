//
//  RxExtension.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

extension Observable {
    func flatMap(emitNextEventBeforeMap emitNextEvent: Bool, mapping: @escaping (E) -> Observable<E>) -> Observable<E> {
        return flatMap { (intermediate: E) -> Observable<E> in
            let mapped = mapping(intermediate)
            guard emitNextEvent else { return mapped }
            return .merge([.of(intermediate), mapped])
        }
    }
}
