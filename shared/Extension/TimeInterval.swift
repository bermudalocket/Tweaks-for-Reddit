//
//  TimeInterval.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

extension TimeInterval {
    static func seconds(_ n: Int) -> TimeInterval {
        TimeInterval(n)
    }
    static func minutes(_ n: Int) -> TimeInterval {
        TimeInterval(n*60)
    }
}
