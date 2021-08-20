//
//  DefaultsService.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public protocol DefaultsService {
    func bool(forKey: String) -> Bool
    func double(forKey: String) -> Double
    func getString(_ key: String) -> String?
    func getObject(_ key: String) -> Any?
    func set(_ value: Any?, forKey: String)
}

public class DefaultsServiceLive: DefaultsService {
    public func bool(forKey: String) -> Bool {
        Redditweaks.defaults.bool(forKey: forKey)
    }
    public func double(forKey: String) -> Double {
        Redditweaks.defaults.double(forKey: forKey)
    }
    public func getString(_ key: String) -> String? {
        Redditweaks.defaults.string(forKey: key)
    }
    public func getObject(_ key: String) -> Any? {
        Redditweaks.defaults.object(forKey: key)
    }
    public func set(_ value: Any?, forKey: String) {
        Redditweaks.defaults.set(value, forKey: forKey)
    }
}

public class DefaultsServiceMock: DefaultsService {
    private var internalStorage = [String: Any]()
    public func bool(forKey: String) -> Bool {
        internalStorage[forKey] as? Bool ?? false
    }
    public func double(forKey: String) -> Double {
        internalStorage[forKey] as? Double ?? 0
    }
    public func getString(_ key: String) -> String? {
        internalStorage[key] as? String
    }
    public func getObject(_ key: String) -> Any? {
        internalStorage[key]
    }
    public func set(_ value: Any?, forKey: String) {
        logService("Set key \(forKey) to \(value.debugDescription)", service: .defaults)
        internalStorage[forKey] = value
    }
}
