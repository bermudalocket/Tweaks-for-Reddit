//
//  Reducer.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import StoreKit
import SwiftUI
import TFRCompose
import TFRCore

public typealias PopoverStore = Store<PopoverState, PopoverAction, TFREnvironment>

extension PopoverStore {
    public static let preview = PopoverStore(
        initialState: PopoverState(),
        reducer: popoverReducer,
        environment: .shared
    )
}

extension Store where State == PopoverState, Action == PopoverAction {
    func binding(for feature: Feature) -> Binding<Bool> {
        Binding<Bool> {
            TweaksForReddit.defaults.bool(forKey: feature.key)
        } set: {
            self.send(.setFeatureState(feature: feature, enabled: $0))
        }
    }
}

public struct PopoverState: Equatable {
    var redditState: RedditState = .init()

    var isShowingWhatsNew: Bool = false

    var features: [Feature] = Feature.features
    var favoriteSubreddits: [FavoriteSubreddit] = []

    var favoriteSubredditListSortingMethod = FavoriteSubredditSortingMethod.alphabetical
    var favoriteSubredditListHeight = FavoriteSubredditListHeight.medium
}

public enum PopoverAction: Equatable {
    case load
    case save
    case askForReview
    case copyDebugInfo
    case openFeedbackEmail

    case showWhatsNew(_ isDisplayed: Bool)

    case reddit(_ action: RedditAction)

    case setFeatureState(feature: Feature, enabled: Bool)

    case addFavoriteSubreddit(_ subreddit: String)
    case deleteFavoriteSubreddit(_ subreddit: FavoriteSubreddit)
    case openFavoriteSubreddit(_ subreddit: FavoriteSubreddit)
    case moveFavoriteSubreddit(indices: IndexSet, newOffset: Int)
    case setFavoriteSubredditsListHeight(height: FavoriteSubredditListHeight)
    case setFavoriteSubredditSortingMethod(method: FavoriteSubredditSortingMethod)
}

let popoverReducer = Reducer<PopoverState, PopoverAction, TFREnvironment> { state, action, env in
    logReducer("popoverReducer: \(action)")
    switch action {
        case .showWhatsNew(let isDisplayed):
            state.isShowingWhatsNew = isDisplayed

        case .copyDebugInfo:
            NSPasteboard.general.clearContents()
            var info = """
            \(TweaksForReddit.debugInfo)
            """
            let cnt = env.coreData.container
            info.append("""
            ---
            Container: \(cnt.name)
            View Context: \(cnt.viewContext)
            Staleness: \(cnt.viewContext.stalenessInterval)
            Retain: \(cnt.viewContext.retainsRegisteredObjects)
            Model: \(cnt.managedObjectModel.versionIdentifiers)
            """)
            NSPasteboard.general.setString(info, forType: .string)

        case .openFeedbackEmail:
            guard let versionInfo = TweaksForReddit.debugInfo.addingPercentEncoding(withAllowedCharacters: .alphanumerics),
                  let url = URL(string: "mailto:support@bermudalocket.com?subject=Tweaks%20for%20Reddit%20Feedback&body=\(versionInfo)") else {
                      return .none
                  }
            NSWorkspace.shared.open(url)

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

        case .openFavoriteSubreddit(let subreddit):
            subreddit.open()

        case .setFavoriteSubredditsListHeight(height: let height):
            state.favoriteSubredditListHeight = height
            env.defaults.set(height.heightInPixels, forKey: .favoriteSubredditListHeight)

        case .reddit(let redditAction):
            return redditReducer(&state.redditState, redditAction, env)
                .map(PopoverAction.reddit)
                .eraseToAnyPublisher()

        case .load:
            if let sort = env.defaults.get(.favoriteSubredditListSortingMethod) as? String {
                state.favoriteSubredditListSortingMethod = .fromDescription(sort) ?? .alphabetical
            }
            if let height = env.defaults.get(.favoriteSubredditListHeight) as? Int {
                state.favoriteSubredditListHeight = FavoriteSubredditListHeight.fromRawValue(height) ?? .medium
            }
            state.favoriteSubreddits = env.coreData.favoriteSubreddits
            if !(env.defaults.get(.didPurchaseLiveCommentPreviews) as? Bool ?? false) && env.defaults.bool(forKey: Feature.liveCommentPreview.key) {
                env.defaults.set(false, forKey: Feature.liveCommentPreview.key)
            }
            if let lastVersion = env.defaults.get(.lastWhatsNewVersion) as? String {
                let numeric = Int(lastVersion.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")) ?? -1
                let thisVersionNumeric = Int(TweaksForReddit.version.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "")) ?? Int.max
                state.isShowingWhatsNew = (numeric < thisVersionNumeric)
            }

        case .save:
            try? env.coreData.container.viewContext.save()

        case .askForReview:
            let timeNow = Date().timeIntervalSince1970
            if let last = env.defaults.get(.lastReviewRequestTimestamp) as? Double, last + (60*60*24*365 / 3) < timeNow {
                SKStoreReviewController.requestReview()
                env.defaults.set(timeNow, forKey: .lastReviewRequestTimestamp)
            }

        case .setFeatureState(feature: let feature, enabled: let isEnabled):
            env.defaults.set(isEnabled, forKey: feature.key)

        case .addFavoriteSubreddit(let subreddit):
            guard subreddit != "" else {
                return .none
            }
            guard !env.coreData.favoriteSubreddits.compactMap(\.name).contains(subreddit) else {
                return .none
            }
            let newFavoriteSub = FavoriteSubreddit(context: env.coreData.container.viewContext)
            newFavoriteSub.name = subreddit
            state.favoriteSubreddits.append(newFavoriteSub)

    }
    return .none
}
