//
//  TFREnvironment.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SafariServices

public struct TFREnvironment {

    public static let shared = Self(
        oauth: RedditService(),
        coreData: CoreDataService(inMemory: false),
        defaults: DefaultsServiceLive(),
        keychain: KeychainServiceLive(),
        appStore: AppStoreService()
    )

    public var reddit: RedditCommunicating
    public var coreData: CoreDataService
    public var defaults: DefaultsService
    public var keychain: KeychainService
    public var appStore: AppStoreService

    init(oauth: RedditCommunicating, coreData: CoreDataService, defaults: DefaultsService, keychain: KeychainService, appStore: AppStoreService) {
        self.reddit = oauth
        self.coreData = coreData
        self.defaults = defaults
        self.keychain = keychain
        self.appStore = appStore
    }

}

import Combine

extension TFREnvironment {

    /// Used for SwiftUI preview providers only.
    public static func mocked() -> TFREnvironment {
        TFREnvironment(
            oauth: RedditServiceMocked(),
            coreData: CoreDataService(inMemory: true),
            defaults: DefaultsServiceMock(),
            keychain: KeychainServiceMock(),
            appStore: AppStoreService()
        )
    }

    private struct RedditServiceMocked: RedditCommunicating {
        func begin(state: String) { }
        func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, RedditError> {
            Just(Tokens(accessToken: "mocked-Access-Token", refreshToken: "mocked-Refresh-Token"))
                .setFailureType(to: RedditError.self)
                .eraseToAnyPublisher()
        }
        func getUserData(tokens: Tokens) -> AnyPublisher<UserData, RedditError> {
            Just(UserData.mock)
                .setFailureType(to: RedditError.self)
                .eraseToAnyPublisher()
        }
        func getMessages(tokens: Tokens) -> AnyPublisher<[UnreadMessage], RedditError> {
            Just([])
                .setFailureType(to: RedditError.self)
                .eraseToAnyPublisher()
        }
        func getHiddenPosts(tokens: Tokens, username: String, after: Post?, before: Post?) -> AnyPublisher<[Post], RedditError> {
            Just([
                Post(subreddit: "mocking", title: "This is a mocked post", permalink: "", name: "t3_mocked")
            ])
                .setFailureType(to: RedditError.self)
                .eraseToAnyPublisher()
        }
        func unhide(tokens: Tokens, posts: [Post]) -> AnyPublisher<Bool, RedditError> {
            Just(true)
                .setFailureType(to: RedditError.self)
                .eraseToAnyPublisher()
        }
    }
}
