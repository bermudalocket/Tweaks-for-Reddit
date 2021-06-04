//
//  ThreadCommentCount.swift
//  redditweaks
//
//  Created by Michael Rippe on 5/31/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import CoreData

extension ThreadCommentCount {
    var count: Int {
        get { Int(internalCount) }
        set { internalCount = Int64(newValue) }
    }
}
