//
//  WindowAlwaysComesToFrontTest.swift
//  WindowAlwaysComesToFrontTest
//
//  Created by Michael Rippe on 9/14/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import XCTest

class WindowAlwaysComesToFrontTest: XCTestCase {

    func testWindowAlwaysComesToFront() throws {
        let app = XCUIApplication()
        app.launch()
        let windows = app.windows
        var foundFront = false
        for i in 0...windows.count {
            let window = windows.element(boundBy: i)
            if window.isHittable {
                foundFront = true
                break
            }
        }
        XCTAssertTrue(foundFront)
    }

}
