//
//  RedditStore.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import AppKit
import Combine
import Foundation
import TFRCompose
import TFRCore

typealias RedditStore = Store<RedditState, RedditAction, TFREnvironment>

struct RedditState: Equatable {
    var isShowingMailView = false

    var userData: UserData?
    var unreadMessages: [UnreadMessage]?
    var hiddenPosts: [Post]?
    var hiddenPostsPage: Int = 1
    var postsBeingUnhidden = [Post]()

    var oauthError: RedditError? = nil
}

public enum RedditAction: Equatable {
    case openPostHistory
    case openCommentHistory

    case setIsShowingMailView(_ state: Bool)

    case setOAuthError(_ error: RedditError)

    case fetchUserData
    case updateUserData(_ userData: UserData)

    case fetchHiddenPosts(after: Post? = nil, before: Post? = nil)
    case updateHiddenPosts(_ posts: [Post])
    case unhidePosts(_ posts: [Post])

    case checkForMessages
    case updateMessages(_ messages: [UnreadMessage])
}

let redditReducer = Reducer<RedditState, RedditAction, TFREnvironment> { state, action, env in

    func getTokens() -> Tokens? {
        guard let tokens = env.keychain.getTokens() else {
            state.oauthError = .noToken
            return nil
        }
        return tokens
    }

    logReducer("redditReducer: \(action)")
    switch action {
        case .unhidePosts(let posts):
            state.postsBeingUnhidden.append(contentsOf: posts)
            guard let tokens = env.keychain.getTokens() else {
                state.oauthError = .noToken
                return .none
            }
            return env.reddit.unhide(tokens: tokens, posts: posts)
                .map { result in
                    if !result {
                        logError("failed to unhide post")
                    }
                    return RedditAction.fetchHiddenPosts()
                }
                .catch { AnyPublisher(value: RedditAction.setOAuthError($0)) }
                .eraseToAnyPublisher()

        case .fetchHiddenPosts(after: let after, before: let before):
            state.hiddenPosts = nil
            guard let tokens = env.keychain.getTokens() else {
                state.oauthError = .noToken
                return .none
            }
            guard let username = state.userData?.username else {
                state.oauthError = .noToken
                return .none
            }
            if let _ = after {
                state.hiddenPostsPage += 1
            } else if let _ = before {
                state.hiddenPostsPage -= 1
            }
            return env.reddit.getHiddenPosts(tokens: tokens, username: username, after: after, before: before)
                .map(RedditAction.updateHiddenPosts)
                .catch { error in
                    return AnyPublisher(value: RedditAction.setOAuthError(RedditError.wrapping(message: "\(error)")))
                }
                .eraseToAnyPublisher()

        case .updateHiddenPosts(let posts):
            state.postsBeingUnhidden = []
            state.hiddenPosts = posts

        case .setIsShowingMailView(let isShowingMailView):
            state.isShowingMailView = isShowingMailView

        case .openPostHistory:
            guard let username = state.userData?.username else {
                return .none
            }
            NSWorkspace.shared.open(URL(string: "https://www.reddit.com/user/\(username)/submitted/")!)

        case .openCommentHistory:
            guard let username = state.userData?.username else {
                return .none
            }
            NSWorkspace.shared.open(URL(string: "https://www.reddit.com/user/\(username)/comments/")!)

        case .setOAuthError(let error):
            state.oauthError = error

        case .updateMessages(let messages):
            env.defaults.set(messages.count, forKey: "newMessageCount")
            messages.forEach(NotificationService.shared.send(msg:))
            state.unreadMessages = messages

        case .checkForMessages:
            env.defaults.set(nil, forKey: "newMessageCount")
            guard let tokens = env.keychain.getTokens() else {
                state.oauthError = .noToken
                return .none
            }
            return env.reddit.getMessages(tokens: tokens)
                .map(RedditAction.updateMessages)
                .catch { AnyPublisher(value: RedditAction.setOAuthError($0)) }
                .eraseToAnyPublisher()

        case .updateUserData(let userData):
            state.userData = userData

        case .fetchUserData:
            guard let tokens = env.keychain.getTokens() else {
                state.oauthError = .noToken
                return .none
            }
            return env.reddit.getUserData(tokens: tokens)
                .map(RedditAction.updateUserData)
                .catch { AnyPublisher(value: RedditAction.setOAuthError($0)) }
                .eraseToAnyPublisher()
    }
    return .none
}
