//
//  redditweaksTests.swift
//  redditweaksTests
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/26/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import XCTest
import Combine
@testable import Tweaks_for_Reddit_Extension

class Desc: NSEntityDescription {
}

class MockFavoriteSubreddit: FavoriteSubreddit {

    init(name: String) {
        super.init(entity: Desc(), insertInto: nil)
    }

}

class redditweaksTests: XCTestCase {

    func testNoDuplicateDictionaryKeys() {
        let view = FavoriteSubredditView(subreddit: MockFavoriteSubreddit(name: "macOS"))
        view.emojiMap.keys.forEach { key in
            XCTAssertTrue(view.emojiMap.keys.filter { $0 == key }.count == 1)
        }
        view.sfSymbolsMap.keys.forEach { key in
            XCTAssertTrue(view.sfSymbolsMap.keys.filter { $0 == key }.count == 1)
        }
    }

    func testFetchRequest() {
        let vc = PersistenceController.shared.container.viewContext

        let testSub = FavoriteSubreddit(context: vc)
        testSub.name = "Apple"

        guard let favSubs = PersistenceController.shared.getFavoriteSubreddits() else {
            XCTFail()
            return
        }

        XCTAssertTrue(favSubs.contains { $0 == "Apple" })
    }

    func testCoreDataAddDelete() {
        let vc = PersistenceController.shared.container.viewContext

        // add
        let sub = FavoriteSubreddit(context: vc)
        sub.name = "macOS"
        XCTAssertEqual(["macOS"], PersistenceController.shared.getFavoriteSubreddits())

        // delete
        vc.delete(sub)
        XCTAssertEqual([], PersistenceController.shared.getFavoriteSubreddits())
    }

    func testBuildJavascript() {
        let safari = SafariExtensionHandler(persistence: .preview)
        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseAutoModerator), "collapseAutoModerator()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .customSubredditBar), "customSubredditBar(['macOS'])")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseChildComments), "collapseChildComments()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideAds), "hideAds()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideNewRedditButton), "hideNewRedditButton()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideRedditPremiumBanner), "hideRedditPremiumBanner()")
    }

    func testStoreKit() {
        let sk = IAPHelper.shared
        XCTAssert(sk.canMakePayments)
        XCTAssert(sk.products.count > 0)

        let product = sk.products.first!
        XCTAssertEqual(product.localizedTitle, "Comment Markdown Live Preview")
        XCTAssertEqual(product.price, NSDecimalNumber(floatLiteral: 0.99))
    }

}



