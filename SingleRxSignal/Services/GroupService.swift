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
    func getGroup(fetchFrom: FetchFrom) -> Observable<Group>
}

final class GroupService: GroupServiceProtocol {
    typealias Router = GroupRouter
    
    let httpClient: HTTPClientProtocol
    
    init(httpClient: HTTPClientProtocol) {
        self.httpClient = httpClient
    }
    
    func getGroup(fetchFrom: FetchFrom = .default) -> Observable<Group> {
        log.info("GETTING GROUP")
        return get(router: Router.group, fetchFrom: fetchFrom)
    }
}

