//
//  Tweaks for RedditTests.swift
//  Tweaks for RedditTests
//  5.0
//  10.16
//
//  Created by Michael Rippe on 6/26/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import XCTest
@testable import Tweaks_for_Reddit

class TweaksForRedditTests: XCTestCase {

    func testAllFeaturesAreAssignedAPageType() {
        Feature.features.forEach { feature in
            XCTAssertTrue(RedditPageType.allCases.map { $0.features.contains(feature) }.count >= 1)
        }
    }

    func testFetchRequest() {
        let vc = PersistenceController.shared.container.viewContext

        let testSub = FavoriteSubreddit(context: vc)
        testSub.name = "Apple"

        XCTAssertTrue(PersistenceController.shared.favoriteSubreddits.contains { $0 == "Apple" })
    }

    func testCoreDataAddDelete() {
        let vc = PersistenceController.shared.container.viewContext

        let uuid = UUID().uuidString

        // add
        let sub = FavoriteSubreddit(context: vc)
        sub.name = uuid
        XCTAssertTrue(PersistenceController.shared.favoriteSubreddits.contains { $0 == uuid })

        // delete
        vc.delete(sub)
        XCTAssertTrue(!PersistenceController.shared.favoriteSubreddits.contains { $0 == uuid })
    }

    func testBuildJavascript() {
        let safari = SafariExtensionHandler()
        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseAutoModerator), "collapseAutoModerator()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .collapseChildComments), "collapseChildComments()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideAds), "hideAds()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideNewRedditButton), "hideNewRedditButton()")
        XCTAssertEqual(safari.buildJavascriptFunction(for: .hideRedditPremiumBanner), "hideRedditPremiumBanner()")
    }

}



