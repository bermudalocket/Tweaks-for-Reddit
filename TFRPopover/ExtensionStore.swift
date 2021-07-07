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
import TfRCompose
import TfRGlobals

typealias ExtensionStore = Store<ExtensionState, ExtensionAction, TFREnvironment>

extension ExtensionStore {
    static let mock = ExtensionStore(
        initialState: .mock,
        reducer: extensionReducer,
        environment: .mock
    )
}

extension Store where State == ExtensionState, Action == ExtensionAction {
    func binding(for feature: Feature) -> Binding<Bool> {
        Binding<Bool> {
            Redditweaks.defaults.bool(forKey: feature.key)
        } set: {
            self.send(.setFeatureState(feature: feature, enabled: $0))
        }
    }
}


struct ExtensionState: Equatable {
    var redditState: RedditState = .live
    var iapState: IAPState?

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

enum ExtensionError: Error {
    case favoriteSubredditInvalid
    case favoriteSubredditRedundant
}

enum ExtensionAction: Equatable {
    case setFeatureState(feature: Feature, enabled: Bool)

    case setFavoriteSubredditTextFieldContents(text: String)
    case setFavoriteSubredditsListHeight(height: FavoriteSubredditListHeight)
    case setFavoriteSubredditSortingMethod(method: FavoriteSubredditSortingMethod)

    case addFavoriteSubreddit(_ subreddit: String)
    case deleteFavoriteSubreddit(_ subreddit: FavoriteSubreddit)
    case openFavoriteSubreddit(_ subreddit: FavoriteSubreddit)

    case askForReview
    case openAppToOAuth

    case load
    case save

    case reddit(_ action: RedditAction)

    case resolveError(_ error: ExtensionError)
}

// MARK: - extension reducer

let extensionReducer = Reducer<ExtensionState, ExtensionAction, TFREnvironment> { state, action, env in
    logReducer("extensionReducer: \(action)")
    switch action {
        case .setFavoriteSubredditSortingMethod(method: let method):
            state.favoriteSubredditListSortingMethod = method

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
            if let height = env.defaults.getObject("favoriteSubredditListHeight") as? Int {
                state.favoriteSubredditListHeight = FavoriteSubredditListHeight.fromRawValue(height) ?? .medium
            }
            state.canMakePurchases = SKPaymentQueue.canMakePayments()
            state.favoriteSubreddits = env.coreData.favoriteSubreddits
            state.iapState = env.coreData.iapState
            log("Loaded state: \(state)")

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
            Redditweaks.defaults.set(isEnabled, forKey: feature.key)

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
