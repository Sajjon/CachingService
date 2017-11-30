//
//  GroupService.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-23.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation
import RxSwift

protocol GroupServiceProtocol: Service {
    func getGroup(fromSource source: ServiceSource) -> Observable<Group>
}

final class GroupService: GroupServiceProtocol {
    typealias Router = GroupRouter
    
    let httpClient: HTTPClientProtocol
    
    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    func getGroup(fromSource source: ServiceSource = .default) -> Observable<Group> {
        log.info("GETTING GROUP")
        return get(request: Router.group, from: source)
    }
}

