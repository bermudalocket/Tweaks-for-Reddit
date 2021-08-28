//
//  ExtensionState.swift
//  ExtensionState
//
//  Created by Michael Rippe on 8/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import Tweaks_for_Reddit_Core

struct ExtensionState: Equatable {

    var redditState: RedditState = .live

    var features = Feature.features
    var favoriteSubreddits: [FavoriteSubreddit] = []

    var canMakePurchases: Bool = true
    var didPurchaseLiveCommentPreviews: Bool = false

    var newToOAuthFeatures = true
    var enableOAuthFeatures = true

    var newFavoriteSubredditTextField = ""
    var favoriteSubredditListSortingMethod = FavoriteSubredditSortingMethod.alphabetical
    var favoriteSubredditListHeight: FavoriteSubredditListHeight = .medium

    var isShowingFavoriteSubredditEmptyError = false
    var isShowingFavoriteSubredditAlreadyExists = false

}

extension ExtensionState {

    static let live = ExtensionState()

    static let mock = ExtensionState(
        redditState: .mock,
        favoriteSubreddits: [
            FavoriteSubredditMock(name: "swiftui", position: 0),
            FavoriteSubredditMock(name: "trees", position: 1),
            FavoriteSubredditMock(name: "apple", position: 2),
            FavoriteSubredditMock(name: "schittscreek", position: 3)
        ],
        canMakePurchases: true,
        didPurchaseLiveCommentPreviews: false
    )

}
