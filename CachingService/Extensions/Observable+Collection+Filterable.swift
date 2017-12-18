//
//  Observable+Collection+Filterable.swift
//  CachingService
//
//  Created by Alexander Cyon on 2017-11-30.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

extension Observable where E: Collection, E.Element: Filterable  {
    typealias F = E.Element
    func filterValues(using filter: FilterConvertible) -> RxSwift.Observable<Element> {
        let filterMatch: (E) -> (E) = { ($0 as! [F]).filter(using: filter) as! E }
        return map { filterMatch($0) }
    }
}

extension Observable where E: Collection  {

    /**
     Returns the elements of the specified sequence or `switchTo` sequence if the sequence is empty.
     
     - seealso: [DefaultIfEmpty operator on reactivex.io](http://reactivex.io/documentation/operators/defaultifempty.html)
     
     - parameter switchTo: Observable sequence being returned when source sequence is empty.
     - returns: Observable sequence that contains elements from switchTo sequence if source is empty, otherwise returns source sequence elements.
     */
    public func ifArrayEmpty(switchTo other: RxSwift.Observable<Element>) -> RxSwift.Observable<Element> {
        return flatMap { (arrayType: Element) -> RxSwift.Observable<Element> in
            guard case let array = (arrayType as! [E.Element]), array.isEmpty else { log.error("not empty -> NOT SWITCHING");return RxSwift.Observable<Element>.just(arrayType) }
            log.error("empty -> SWITCHING")
            return self.withLatestFrom(other)
        }
    }
    
//    func ifArrayEmpty(using filter: FilterConvertible) -> RxSwift.Observable<Element> {
//
//    }
}

