//
//  FavoriteSubredditListHeight.swift
//  TFRPopover
//
//  Created by Michael Rippe on 6/29/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum FavoriteSubredditListHeight: Int, CaseIterable {
    case small = 125, medium = 200, large = 320

    var displayName: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }

    static func fromRawValue(_ value: Int) -> FavoriteSubredditListHeight? {
        allCases.first { $0.rawValue == value }
    }

}
