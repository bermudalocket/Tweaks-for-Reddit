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
@testable import Tweaks_for_Reddit

class redditweaksTests: XCTestCase {

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

    func testCoreDataDelete() {
        let vc = PersistenceController.shared.container.viewContext

        XCTAssertEqual(["macOS"], PersistenceController.shared.getFavoriteSubreddits())

        vc.registeredObjects.forEach { vc.delete($0) }

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

//    func testView() {
//        let view = FavoriteSubredditsSectionView()
//            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//            .environmentObject(AppState())
//
//        view.
//    }

}



