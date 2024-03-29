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
//        app.launchArguments = ["--testing"]
        app.launch()
    }

    func testOAuth() {
        app.buttons["Reddit API Access"].click()
        let startButton = app.buttons["Start OAuth"]
        if startButton.isEnabled {
            app.buttons["Start OAuth"].click()
        } else {
            app.buttons["Restart OAuth"].click()
        }
        
    }

}
