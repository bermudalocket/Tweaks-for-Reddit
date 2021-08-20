//
//  ExtensionAction.swift
//  ExtensionAction
//
//  Created by Michael Rippe on 8/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import Tweaks_for_Reddit_Core

enum ExtensionAction: Equatable {

    case load
    case save

    case setFeatureState(feature: Feature, enabled: Bool)

    case setFavoriteSubredditTextFieldContents(text: String)
    case setFavoriteSubredditsListHeight(height: FavoriteSubredditListHeight)
    case setFavoriteSubredditSortingMethod(method: FavoriteSubredditSortingMethod)

    case addFavoriteSubreddit(_ subreddit: String)
    case deleteFavoriteSubreddit(_ subreddit: FavoriteSubreddit)
    case openFavoriteSubreddit(_ subreddit: FavoriteSubreddit)
    case moveFavoriteSubreddit(indices: IndexSet, newOffset: Int)

    case askForReview
    case openAppToOAuth


    case reddit(_ action: RedditAction)

    case resolveError(_ error: ExtensionError)
    
}
