//
//  FavoriteSubredditSortingMethod.swift
//  Tweaks_for_Reddit_Popover
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

    static func fromDescription(_ description: String) -> FavoriteSubredditSortingMethod? {
        allCases.filter { $0.description == description }.first
    }

}
