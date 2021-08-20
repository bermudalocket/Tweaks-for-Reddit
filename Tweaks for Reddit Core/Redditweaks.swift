//
//  Tweaks for Reddit.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/9/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Foundation
import os

public enum Redditweaks {

    public static let defaults = UserDefaults(suiteName: "group.com.bermudalocket.redditweaks")!

    public static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"

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

}

extension OSLog {

    public static let tfr = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "Signposts")

}
