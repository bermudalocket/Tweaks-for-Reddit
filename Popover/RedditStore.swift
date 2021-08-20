//
//  RedditStore.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import Composable_Architecture
import Tweaks_for_Reddit_Core

typealias RedditStore = Store<RedditState, RedditAction, TFREnvironment>

struct RedditState: Equatable {

    var userData: UserData?
    var unreadMessages: [UnreadMessage]?

    var isShowingOAuthError = false
    var error: String?

    static let live = Self()
    static let mock = Self(userData: .mock)
}

enum RedditAction: Equatable {
    case showOAuthError(_ error: OAuthError)

    case fetchUserData
    case updateUserData(_ userData: UserData)

    case checkForMessages
    case updateMessages(_ messages: [UnreadMessage])
}

let redditReducer = Reducer<RedditState, RedditAction, TFREnvironment> { state, action, env in
    logReducer("redditReducer: \(action)")
    switch action {
        case .showOAuthError(let error):
            state.isShowingOAuthError = true
            state.error = "\(error.localizedDescription)"

        case .updateMessages(let messages):
            env.defaults.set(messages.count, forKey: "newMessageCount")
            state.unreadMessages = messages

        case .checkForMessages:
            guard let tokens = env.keychain.getTokens() else {
                return Just(RedditAction.showOAuthError(.noToken)).eraseToAnyPublisher()
            }
            return env.oauth
                .request(tokens: tokens, endpoint: .unreadMessages, isRetry: false)
                .decode(type: UnreadMessagesResponse.self, decoder: JSONDecoder())
                .map(\.data.children)
                .reduce([UnreadMessage]()) { agg, next in
                    var map = next.map(\.data)
                    map.append(contentsOf: agg)
                    return map
                }
                .map(RedditAction.updateMessages)
                .catch { (error) -> AnyPublisher<RedditAction, Never> in
                    if let error = error as? OAuthError {
                        return Just(RedditAction.showOAuthError(error)).eraseToAnyPublisher()
                    } else {
                        return Just(RedditAction.showOAuthError(.wrapping(message: "\(error)"))).eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()

        case .updateUserData(let userData):
            state.userData = userData

        case .fetchUserData:
            guard let tokens = env.keychain.getTokens() else {
                return Just(RedditAction.showOAuthError(.noToken)).eraseToAnyPublisher()
            }
            return env.oauth
                .request(tokens: tokens, endpoint: .me, isRetry: false)
                .decode(type: UserData.self, decoder: JSONDecoder())
                .map(RedditAction.updateUserData)
                .catch { (error) -> AnyPublisher<RedditAction, Never> in
                    if let error = error as? OAuthError {
                        return Just(RedditAction.showOAuthError(error))
                            .eraseToAnyPublisher()
                    } else {
                        return Just(RedditAction.showOAuthError(.wrapping(message: "\(error)")))
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
    }
    return .none
}
