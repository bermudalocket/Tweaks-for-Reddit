//
//  TFRCore_Tests.swift
//  TFRCore Tests
//
//  Created by Michael Rippe on 9/11/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import XCTest
@testable import TFRCore

class TFRCore_Tests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testKeychain() {
        let keychain = KeychainServiceLive()

        keychain.set("testkey", value: "testvalue")

        XCTAssertEqual(keychain.get("testkey"), "testvalue")
    }

    func testTokens() {
        let keychain = KeychainServiceLive()

        guard let tokens = keychain.getTokens() else {
            XCTFail("No tokens are stored.")
            return
        }

        XCTAssertNotNil(tokens.accessToken)
        XCTAssertNotNil(tokens.refreshToken)
    }

    func testExample() throws {
        let keychainService = KeychainServiceLive()
        guard let tokens = keychainService.getTokens() else {
            XCTFail("No tokens")
            return
        }

        let waiter = XCTestExpectation(description: "Wait for network request")

        RedditService().getUserData(tokens: tokens)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("error: \(error)")
                }
            } receiveValue: { data in
                XCTAssert(data.username == "thebermudalocket")
                waiter.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [waiter], timeout: 10)
    }

    func testHidden() throws {
        let keychainService = KeychainServiceLive()
        guard let tokens = keychainService.getTokens() else {
            XCTFail("No tokens")
            return
        }

        let waiter = XCTestExpectation(description: "Wait for network request")

        RedditService()
            .getHiddenPosts(tokens: tokens, username: "thebermudalocket")
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("error: \(error)")
                }
            } receiveValue: { listing in
                print(listing)
                waiter.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [waiter], timeout: 10)
    }

    func testGetHiddenPostsAfter() throws {
        let keychainService = KeychainServiceLive()
        guard let tokens = keychainService.getTokens() else {
            XCTFail("No tokens")
            return
        }

        let waiter = XCTestExpectation(description: "Wait for network request")

        let redditService = RedditService()
        redditService
            .getHiddenPosts(tokens: tokens, username: "thebermudalocket")
            .compactMap(\.first)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("error: \(error)")
                }
            } receiveValue: { post in
                redditService.getHiddenPosts(tokens: tokens, username: "thebermudalocket", after: post)
                    .sink { completion in
                        if case let .failure(error) = completion {
                            XCTFail("error: \(error)")
                        }
                    } receiveValue: { posts in
                        XCTAssertFalse(posts.contains(where: { $0.name == post.name }))
                        waiter.fulfill()
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)

        wait(for: [waiter], timeout: 10)
    }

    func testUnhide() throws {
        let keychainService = KeychainServiceLive()
        guard let tokens = keychainService.getTokens() else {
            XCTFail("No tokens")
            return
        }

        let waiter = XCTestExpectation(description: "Wait for network request")

        let redditService = RedditService()
        redditService
            .getHiddenPosts(tokens: tokens, username: "thebermudalocket")
            .compactMap(\.first)
            .map { post in
                redditService.unhide(tokens: tokens, posts: [post])
                    .sink { completion in
                        if case let .failure(error) = completion {
                            XCTFail("error: \(error)")
                        }
                    } receiveValue: { success in
                        if !success {
                            XCTFail()
                        }
                        waiter.fulfill()
                    }
                    .store(in: &self.cancellables)
            }
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("error: \(error)")
                }
            } receiveValue: { success in
            }
            .store(in: &cancellables)

        wait(for: [waiter], timeout: 10)
    }

//    func testFailure() throws {
//
//    }

}

