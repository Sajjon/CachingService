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
    let httpClient: HTTPClientProtocol = HTTPClient()
    func getGroup(fetchFrom: FetchFrom = .default) -> Observable<Group> {
        return get(fetchFrom: fetchFrom)
    }
}

