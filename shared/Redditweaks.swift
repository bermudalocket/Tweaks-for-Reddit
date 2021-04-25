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

enum Redditweaks {

    public static let defaults = UserDefaults(suiteName: "group.com.bermudalocket.redditweaks")!

    public static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"

}
