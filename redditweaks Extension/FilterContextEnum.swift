//
//  FilterContextEnum.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 11/3/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Foundation

enum FilterContext: String {

    case global = "reddit.com"
    case rAll = "reddit.com\\/r\\/all"
    case subs = "reddit.com\\/r\\/[a-zA-Z0-9]+"

    static func getId(for context: FilterContext) -> Int {
        switch context {
            case .global: return 0
            case .rAll: return 1
            case .subs: return 2
        }
    }

    static func matches(_ url: String, context: FilterContext) -> Bool {
        let range = NSRange(location: 0, length: url.utf16.count)
        do {
            let regex = try NSRegularExpression(pattern: context.rawValue)
            return regex.firstMatch(in: url, options: [], range: range) != nil
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return false
        }
    }

}
