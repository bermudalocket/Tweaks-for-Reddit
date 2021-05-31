//
//  ThreadCommentCount+count.swift
//  redditweaks
//
//  Created by Michael Rippe on 5/30/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

extension ThreadCommentCount {
    var count: Int {
        get { Int(internalCount) }
        set { internalCount = Int64(newValue) }
    }
}
