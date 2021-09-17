//
//  FavoriteSubreddit.swift
//  TFRCore
//
//  Created by Michael Rippe on 5/31/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import CoreData

extension FavoriteSubreddit {
    public var position: Int {
        get { Int(internalPosition) }
        set { internalPosition = Int16(newValue) }
    }
}
