//
//  FavoriteSubredditListHeight.swift
//  Tweaks_for_Reddit_Popover
//
//  Created by Michael Rippe on 6/29/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct FavoriteSubredditListHeight: Equatable, Hashable {
    public let heightInPixels: Int
    public let displayName: String
}

extension FavoriteSubredditListHeight {
    static func fromRawValue(_ value: Int) -> FavoriteSubredditListHeight? {
        allCases.first { $0.heightInPixels == value }
    }
}

extension FavoriteSubredditListHeight {
    public static let small = FavoriteSubredditListHeight(heightInPixels: 125, displayName: "a few")
    public static let medium = FavoriteSubredditListHeight(heightInPixels: 200, displayName: "a bunch")
    public static let large = FavoriteSubredditListHeight(heightInPixels: 320, displayName: "a lot")

    public static let allCases = [ small, medium, large ]
}
