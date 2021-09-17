//
//  TweaksForReddit.swift
//  TFRCore
//
//  Created by Michael Rippe on 7/9/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Foundation
import os

public enum TweaksForReddit {

    public static let bundleId = "com.bermudalocket.redditweaks"

    public static let groupId = "group.\(bundleId)"

    public static let defaults = UserDefaults(suiteName: groupId)!

    public static var version: String {
        let major = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "\(major)-\(build)"
    }

    public static var identifier: UUID {
        guard let stored = defaults.string(forKey: "identifier"), let uuid = UUID(uuidString: stored) else {
            let newId = UUID()
            defaults.setValue(newId.uuidString, forKey: "identifier")
            return newId
        }
        return uuid
    }

    public static let popoverWidth: CGFloat = 350.0

    public static var debugInfo: String {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString
        return "\n\nTFR \(self.version), macOS \(osVersion)"
    }

    public static func symbolForSubreddit(_ subreddit: String) -> String {
        sfSymbolsMap[subreddit] ?? "doc"
    }

    private static let sfSymbolsMap: [String: String] = [
        "apple": "applelogo",
        "art": "paintbrush.fill",
        "books": "books.vertical.fill",
        "consulting": "rectangle.3.offgrid.bubble.left.fill",
        "earthporn": "globe",
        "explainlikeimfive": "questionmark.circle.fill",
        "gaming": "gamecontroller.fill",
        "math": "function",
        "movies": "film.fill",
        "music": "music.quarternote.3",
        "news": "newspaper.fill",
        "pics": "photo.fill",
        "photography": "photo.fill",
        "space": "moon.stars.fill",
        "sports": "sportscourt.fill",
        "television": "tv.fill",
        "todayilearned": "lightbulb.fill",
        "worldnews": "newspaper.fill",

        // apple products
        "iphone": "iphone",
        "ipad": "ipad",
        "ipados": "ipad",
        "ipadosbeta": "ipad",
        "macos": "desktopcomputer",
        "macosbeta": "desktopcomputer",
        "ios": "ipad",
        "iosbeta": "ipad",
        "homepod": "homepod.fill",
    ]

}
