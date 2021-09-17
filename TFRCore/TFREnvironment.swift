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
        appStore: AppStoreService.shared
    )

    public var reddit: RedditServiceProtocol
    public var coreData: CoreDataService
    public var defaults: DefaultsService
    public var keychain: KeychainService
    public var appStore: AppStoreService

    private init(oauth: RedditServiceProtocol, coreData: CoreDataService, defaults: DefaultsService, keychain: KeychainService, appStore: AppStoreService) {
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
            appStore: AppStoreService.shared
        )
    }

    private struct RedditServiceMocked: RedditServiceProtocol {
        func begin(state: String) { }
        func exchangeCodeForTokens(code: String) -> AnyPublisher<Tokens, RedditError> {
            AnyPublisher(value: Tokens(accessToken: "mocked-Access-Token", refreshToken: "mocked-Refresh-Token"))
        }
        func getUserData(tokens: Tokens) -> AnyPublisher<UserData, RedditError> {
            AnyPublisher(value: UserData.mock)
        }
        func getMessages(tokens: Tokens) -> AnyPublisher<[UnreadMessage], RedditError> {
            AnyPublisher(value: [])
        }
        func getHiddenPosts(tokens: Tokens, username: String, after: Post?, before: Post?) -> AnyPublisher<[Post], RedditError> {
            AnyPublisher(value: [
                Post(subreddit: "mocking", title: "This is a mocked post", permalink: "", name: "t3_mocked")
            ])
        }
        func unhide(tokens: Tokens, posts: [Post]) -> AnyPublisher<Bool, RedditError> {
            AnyPublisher(value: true)
        }
    }
}
