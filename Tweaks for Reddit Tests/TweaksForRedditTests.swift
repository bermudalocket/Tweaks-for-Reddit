//
//  Tweaks for RedditTests.swift
//  Tweaks for RedditTests
//  5.0
//  10.16
//
//  Created by Michael Rippe on 6/26/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Combine
import XCTest
@testable import Tweaks_for_Reddit
@testable import Tweaks_for_Reddit_Extension
@testable import Tweaks_for_Reddit_Core
@testable import Composable_Architecture
@testable import Tweaks_for_Reddit_Popover

class TweaksForRedditTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testCheckMessages() {
        let waiter = XCTestExpectation(description: "Check messages")

        let store = Store<RedditState, RedditAction, TFREnvironment>(
            initialState: RedditState(userData: nil, unreadMessages: nil),
            reducer: redditReducer,
            environment: .mock
        )

        store.$state.sink { newState in
            if newState.unreadMessages != nil {
                waiter.fulfill()
            }
        }.store(in: &cancellables)

        store.send(.checkForMessages)

        wait(for: [waiter], timeout: 10)

        XCTAssertNotNil(store.state.unreadMessages)
        XCTAssertEqual(store.state.unreadMessages!.count, 1)

        let message = store.state.unreadMessages!.first!

        XCTAssertEqual(message.author, "thebermudamocket")
        XCTAssertEqual(message.subreddit, "iOSProgramming")
        XCTAssertEqual(message.subject, "comment reply")
    }

    func testOAuth() {
        let waiter = XCTestExpectation(description: "oauth")

        let store: MainAppStore = .mock

        store.$state.sink { newState in
            if newState.didCompleteOAuth {
                waiter.fulfill()
            }
        }.store(in: &cancellables)

        store.send(.beginOAuth)
        store.send(.exchangeCodeForTokens(incomingUrl: URL(string: "rdtwks://oauth?code=mocked")!))

        wait(for: [waiter], timeout: 10)

        XCTAssertTrue(store.state.didCompleteOAuth)
        XCTAssertNil(store.state.error)
    }

    func testAllFeaturesAreAssignedAPageType() {
        Feature.features.forEach { feature in
            XCTAssertTrue(RedditPageType.allCases.map { $0.features.contains(feature) }.count >= 1)
        }
    }
//
//    func testFetchRequest() {
//        let env = TFREnvironment(
//            oauth: .mock,
//            iap: .shared,
//            coreData: .preview,
//            defaults: .mock
//        )
//        let testSub = FavoriteSubreddit(context: PersistenceController.shared.container.viewContext)
//        testSub.name = "Apple"
//        XCTAssertTrue(PersistenceController.shared.favoriteSubreddits.contains { $0.name == "Apple" })
//    }
//
//    func testCoreDataAddDelete() {
//        let vc = PersistenceController.shared.container.viewContext
//
//        let uuid = UUID().uuidString
//
//        // add
//        let sub = FavoriteSubreddit(context: vc)
//        sub.name = uuid
//        XCTAssertTrue(PersistenceController.shared.favoriteSubreddits.contains { $0.name == uuid })
//
//        // delete
//        vc.delete(sub)
//        XCTAssertTrue(!PersistenceController.shared.favoriteSubreddits.contains { $0.name == uuid })
//    }

    func testBuildJavascript() {
//        let safari = SafariExtensionHandler()
//        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseAutoModerator), "collapseAutoModerator()")
//        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseChildComments), "collapseChildComments()")
//        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideAds), "hideAds()")
//        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideNewRedditButton), "hideNewRedditButton()")
//        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideRedditPremiumBanner), "hideRedditPremiumBanner()")
    }

}
