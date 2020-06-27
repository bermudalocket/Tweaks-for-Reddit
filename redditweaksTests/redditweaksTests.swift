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

class redditweaksTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        NSWorkspace.shared.open(URL(string: "rdtwks://verify")!)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
