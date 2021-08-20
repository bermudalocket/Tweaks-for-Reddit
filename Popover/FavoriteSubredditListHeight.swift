//
//  FavoriteSubredditListHeight.swift
//  Tweaks_for_Reddit_Popover
//
//  Created by Michael Rippe on 6/29/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum FavoriteSubredditListHeight: Int, CaseIterable {
    case small = 125, medium = 200, large = 320

    var displayName: String {
        switch self {
            case .small: return "a few"
            case .medium: return "a bunch"
            case .large: return "a lot"
        }
    }

    static func fromRawValue(_ value: Int) -> FavoriteSubredditListHeight? {
        allCases.first { $0.rawValue == value }
    }

}
