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
    func getObject(_ key: String) -> Any?
    func set(_ value: Any?, forKey: String)
}

class DefaultsServiceLive: DefaultsService {
    func bool(forKey: String) -> Bool {
        TweaksForReddit.defaults.bool(forKey: forKey)
    }
    func double(forKey: String) -> Double {
        TweaksForReddit.defaults.double(forKey: forKey)
    }
    func getObject(_ key: String) -> Any? {
        TweaksForReddit.defaults.object(forKey: key)
    }
    func set(_ value: Any?, forKey: String) {
        TweaksForReddit.defaults.set(value, forKey: forKey)
    }
}

class DefaultsServiceMock: DefaultsService {
    private var internalStorage = [String: Any]()
    func bool(forKey: String) -> Bool {
        internalStorage[forKey] as? Bool ?? false
    }
    func double(forKey: String) -> Double {
        internalStorage[forKey] as? Double ?? 0
    }
    func getObject(_ key: String) -> Any? {
        internalStorage[key]
    }
    func set(_ value: Any?, forKey: String) {
        logService("Set key \(forKey) to \(value.debugDescription)", service: .defaults)
        internalStorage[forKey] = value
    }
}
