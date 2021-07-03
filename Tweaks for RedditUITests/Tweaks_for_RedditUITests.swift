//
//  Tweaks_for_RedditUITests.swift
//  Tweaks for RedditUITests
//
//  Created by Michael Rippe on 6/19/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import XCTest

class Tweaks_for_RedditUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["popover-ui-testing"]
        app.launch()
    }

    func testExample() throws {
        XCTAssertFalse(app.checkBoxes["Always use old.reddit.com"].isSelected)
        XCTAssertFalse(app.checkBoxes["Automatically expand images"].isSelected)

        XCTAssertTrue(app.staticTexts["Username"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Post karma"].exists)
        XCTAssertTrue(app.staticTexts["Comment karma"].exists)

        let mailButton = app.buttons["Mail button"]
        XCTAssertTrue(mailButton.exists)
        XCTAssertTrue(mailButton.isEnabled)
        mailButton.click()

        let mailList = app.scrollViews["Mail list"]
        XCTAssertTrue(mailList.exists)
    }

}

class MainAppTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = ["main-ui-testing"]
        app.launch()
    }

    func testExample() throws {
        XCTAssertTrue(app.staticTexts["Welcome to Tweaks for Reddit"].exists)

        let safariButton = app.buttons["Connect to Safari"]
        XCTAssertTrue(safariButton.exists)
        safariButton.click()

        XCTAssertTrue(app.staticTexts["Connect to Safari"].exists)

        let openInSafari = app.buttons["Open in Safari"]
        XCTAssertTrue(openInSafari.exists)
//        openInSafari.click()

        let oauthButton = app.buttons["Reddit API Access"]
        XCTAssertTrue(oauthButton.exists)
        oauthButton.click()
    }

}
