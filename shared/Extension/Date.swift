//
//  Date.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

extension Date {
    static func now() -> TimeInterval {
        Date().timeIntervalSince1970
    }
}
