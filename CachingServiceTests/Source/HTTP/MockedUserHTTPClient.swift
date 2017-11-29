//
//  MockedUserHTTPClient.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-29.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//


import Foundation
@testable import SingleRxSignal
import RxSwift

final class MockedUserHTTPClient: BaseMockedHTTPClient<List<User>> {
    init(mockedEvent: MockedEvent<List<User>>) {
        super.init(mockedEvent: mockedEvent)
    }
}
