//
//  ExtensionReducer.swift
//  ExtensionReducer
//
//  Created by Michael Rippe on 8/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import StoreKit
import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

let extensionReducer = Reducer<ExtensionState, ExtensionAction, TFREnvironment> { state, action, env in
    logReducer("extensionReducer: \(action)")
    switch action {
        case .moveFavoriteSubreddit(indices: let indices, newOffset: let newOffset):
            state.favoriteSubreddits.move(fromOffsets: indices, toOffset: newOffset)
            for favSub in state.favoriteSubreddits {
                favSub.position = state.favoriteSubreddits.firstIndex(of: favSub) ?? -1
            }

        case .setFavoriteSubredditSortingMethod(method: let method):
            state.favoriteSubredditListSortingMethod = method
            env.defaults.set(method.description, forKey: "favoriteSubredditListSortingMethod")

        case .deleteFavoriteSubreddit(let subreddit):
            state.favoriteSubreddits.removeAll { $0 == subreddit }
            env.coreData.container.viewContext.delete(subreddit)
            try? env.coreData.container.viewContext.save()

        case .setFavoriteSubredditTextFieldContents(text: let text):
            state.newFavoriteSubredditTextField = text
 
        case .openFavoriteSubreddit(let subreddit):
            if let name = subreddit.name {
                NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(name)")!)
            }

        case .resolveError(let error):
            switch error {
                case .favoriteSubredditInvalid:
                    state.isShowingFavoriteSubredditEmptyError = false

                case .favoriteSubredditRedundant:
                    state.isShowingFavoriteSubredditAlreadyExists = false
            }

        case .setFavoriteSubredditsListHeight(height: let height):
            state.favoriteSubredditListHeight = height
            env.defaults.set(height.rawValue, forKey: "favoriteSubredditListHeight")

        case .reddit(let redditAction):
            return redditReducer(&state.redditState, redditAction, env)
                .map(ExtensionAction.reddit)
                .eraseToAnyPublisher()

        case .openAppToOAuth:
            NSWorkspace.shared.open(URL(string: "rdtwks://auth")!)

        case .load:
            state.enableOAuthFeatures = env.defaults.bool(forKey: "enableOAuthFeatures")
            state.newToOAuthFeatures = env.defaults.bool(forKey: "newToOAuthFeatures")
            if let sort = env.defaults.getObject("favoriteSubredditListSortingMethod") as? String {
                state.favoriteSubredditListSortingMethod = .fromDescription(sort) ?? .alphabetical
            }
            if let height = env.defaults.getObject("favoriteSubredditListHeight") as? Int {
                state.favoriteSubredditListHeight = FavoriteSubredditListHeight.fromRawValue(height) ?? .medium
            }
            state.canMakePurchases = SKPaymentQueue.canMakePayments()
            state.favoriteSubreddits = env.coreData.favoriteSubreddits
            state.didPurchaseLiveCommentPreviews = env.coreData.iapState?.liveCommentPreviews ?? false
            if !state.didPurchaseLiveCommentPreviews && env.defaults.bool(forKey: Feature.liveCommentPreview.key) {
                env.defaults.set(false, forKey: Feature.liveCommentPreview.key)
            }

        case .save:
            try? env.coreData.container.viewContext.save()

        case .askForReview:
            let timeNow = Date().timeIntervalSince1970
            let last = env.defaults.double(forKey: "lastReviewRequestTimestamp")
            if last + (60*60*24*365 / 3) < timeNow {
                SKStoreReviewController.requestReview()
                env.defaults.set(timeNow, forKey: "lastReviewRequestTimestamp")
            }

        case .setFeatureState(feature: let feature, enabled: let isEnabled):
            if feature == .liveCommentPreview && isEnabled && !(env.coreData.iapState?.liveCommentPreviews ?? false) {
                NSWorkspace.shared.open(URL(string: "rdtwks://iap")!)
                return .none
            }
            env.defaults.set(isEnabled, forKey: feature.key)

        case .addFavoriteSubreddit(let subreddit):
            guard subreddit != "" else {
                state.isShowingFavoriteSubredditEmptyError = true
                return .none
            }
            guard !env.coreData.favoriteSubreddits.compactMap(\.name).contains(subreddit) else {
                state.isShowingFavoriteSubredditAlreadyExists = true
                return .none
            }
            let newFavoriteSub = FavoriteSubreddit(context: env.coreData.container.viewContext)
            newFavoriteSub.name = subreddit
            state.favoriteSubreddits.append(newFavoriteSub)

    }
    return .none
}
