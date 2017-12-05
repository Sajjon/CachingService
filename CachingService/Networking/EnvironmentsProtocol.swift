//
//  EnvironmentsProtocol.swift
//  CommonAPI
//
//  Created by Alexander Cyon on 2017-10-16.
//  Copyright © 2017 Nordic Choice Hotels. All rights reserved.
//

import Foundation
//import Basics

private let environmentsPlistKey = "LSEnvironment"
private let configurationPlistKey = "CONFIGURATION"

public enum Configuration: String {
    case debug = "Debug"
    case release = "Release"
}

public enum EnvironmentKey: String {
    case baseUrl = "API_BASE_URL"
}

public protocol EnvironmentsProtocol {
    var configuration: Configuration { get }
    func value<Value>(for key: EnvironmentKey) -> Value
}

public typealias Plist = [String: Any]
public final class Environments {
    private let values: Plist

    public init(infoPlist: Plist) {
        guard
            let environments = infoPlist[environmentsPlistKey] as? Plist
            else { incorrectImplementation }
        self.values = environments
    }    
}

extension Environments: EnvironmentsProtocol {}

public extension Environments {
    var configuration: Configuration {
        guard
            let configurationString = values[configurationPlistKey] as? String,
            let configuration = Configuration(rawValue: configurationString)
            else { incorrectImplementation }
        return configuration
    }

    func value<Value>(for key: EnvironmentKey) -> Value {
        guard
            let plist = values[key.rawValue] as? Plist,
            let value = plist[configuration.rawValue] as? Value
            else { incorrectImplementation }
        return value
    }
}

var incorrectImplementation: Never { fatalError("incorrect implementation") }
