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
    func get(_ forKey: DefaultsKey) -> Any?
    func set(_ value: Any?, forKey: String)
}

public extension DefaultsService {
    func get(_ forKey: DefaultsKey) -> Any? {
        getObject(forKey.rawValue)
    }
    func exists(_ forKey: DefaultsKey) -> Bool {
        get(forKey) != nil
    }
    func set(_ value: Any?, forKey: DefaultsKey) {
        set(value, forKey: forKey.rawValue)
    }
}

public enum DefaultsKey: String {
    case firstLaunch
    case selectedTab
    case oauthStatusCode
    case didCompleteOAuth
    case lastWhatsNewVersion
    case firstLaunchIsDefinite
    case lastReviewRequestTimestamp
    case favoriteSubredditListHeight
    case favoriteSubredditListSortingMethod
    case didPurchaseLiveCommentPreviews
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

public class DefaultsServiceMock: DefaultsService {
    public init() { }
    private var internalStorage = [String: Any]()
    public func bool(forKey: String) -> Bool {
        internalStorage[forKey] as? Bool ?? false
    }
    public func double(forKey: String) -> Double {
        internalStorage[forKey] as? Double ?? 0
    }
    public func getObject(_ key: String) -> Any? {
        internalStorage[key]
    }
    public func set(_ value: Any?, forKey: String) {
        logService("Set key \(forKey) to \(value.debugDescription)", service: .defaults)
        internalStorage[forKey] = value
    }
}
