//
//  MockedIntegerHTTPClient.swift
//  SingleRxSignalTests
//
//  Created by Alexander Cyon on 2017-11-15.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation

final class MockedIntegerHTTPClient: BaseMockedHTTPClient<Int> {
    init(mockedEvent: MockedEvent<Int>) {
        super.init(mockedEvent: mockedEvent)
    }
}
