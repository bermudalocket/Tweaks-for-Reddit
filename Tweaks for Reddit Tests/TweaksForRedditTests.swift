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
@testable import TFRCore
@testable import TFRCompose
@testable import Tweaks_for_Reddit_Popover

extension Task where Success == Never, Failure == Never {
    public static func sleep(_ seconds: Int) async throws {
        try await Task.sleep(nanoseconds: .init(UInt64(seconds) * NSEC_PER_SEC))
    }
}

class TweaksForRedditTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func testCoreDataSetup() {
        let cd = TFREnvironment.shared.coreData
        let container = cd.container
        XCTAssertNotNil(container)
        XCTAssertNotNil(container.persistentStoreCoordinator)
        XCTAssertTrue(container.persistentStoreCoordinator.persistentStores.count > 0)
    }

    func testAddFavoriteSubreddit() {
        let store = Store<PopoverState, PopoverAction, TFREnvironment>(
            initialState: PopoverState(),
            reducer: popoverReducer,
            environment: .shared
        )
        _ = TFREnvironment.shared.coreData.favoriteSubreddits

        store.send(.addFavoriteSubreddit("test"))

        XCTAssertTrue(store.state.favoriteSubreddits.contains { $0.name == "test" })
    }

    func testICloudKeyValueStore() async throws {
        let randomId = UUID().uuidString
        let iCloud = NSUbiquitousKeyValueStore.default

        iCloud.set(true, forKey: randomId)

        iCloud.synchronize()

        XCTAssert(iCloud.bool(forKey: randomId))
    }

    func testReceipt() async throws {
        let store = Store<MainAppState, MainAppAction, TFREnvironment>(
            initialState: MainAppState(tab: .liveCommentPreview),
            reducer: mainAppReducer,
            environment: .shared
        )

        NSUbiquitousKeyValueStore.default.set(true, forKey: InAppPurchase.liveCommentPreview.productId)

        store.send(.restorePurchases)

        XCTAssert(store.state.receiptValidationStatus == .valid)
    }

    func testOAuth() {
        let waiter = XCTestExpectation(description: "oauth")

        let store: MainAppStore = MainAppStore(
            initialState: .init(),
            reducer: .none,
            environment: TFREnvironment(
                oauth: RedditService(),
                coreData: CoreDataService.init(inMemory: true),
                defaults: DefaultsServiceMock(),
                keychain: KeychainServiceMock(),
                appStore: AppStoreService()
            )
        )

        store.$state.sink { newState in
            if newState.oauthState == .completed {
                waiter.fulfill()
            }
        }.store(in: &cancellables)

        store.send(.beginOAuth)
        store.send(.exchangeCodeForTokens(incomingUrl: "rdtwks://oauth?code=mocked"))

        wait(for: [waiter], timeout: 10)

        XCTAssertTrue(store.state.oauthState == .completed)
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
