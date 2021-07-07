//
//  FavoriteSubredditSortingMethod.swift
//  TFRPopover
//
//  Created by Michael Rippe on 7/6/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum FavoriteSubredditSortingMethod: CaseIterable {
    case alphabetical
    case manual

    var description: String {
        switch self {
            case .alphabetical:
                return "alphabetically"

            case .manual:
                return "manually"
        }
    }

}
