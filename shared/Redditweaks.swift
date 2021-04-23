//
//  Redditweaks.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/9/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation

struct Redditweaks {

    public static let repoURL = URL(string: "https://www.github.com/bermudalocket/redditweaks/issues/new/choose")!

    public static let defaults = UserDefaults(suiteName: "group.com.bermudalocket.redditweaks") ?? UserDefaults.standard

    public static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"

    public static let isFromMacAppStore = Bundle.main.object(forInfoDictionaryKey: "MAC_APP_STORE") as? Bool ?? true

}
