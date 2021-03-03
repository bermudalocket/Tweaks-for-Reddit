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
@testable import redditweaks

class redditweaksTests: XCTestCase {

    func testSettings() {
        let state = AppState()
        let binding = state.bindingForFeature(.collapseAutoModerator)
        let currentFeatureState = binding.wrappedValue
        binding.projectedValue.wrappedValue.toggle()
        XCTAssert(currentFeatureState != binding.wrappedValue)
    }

    func testVersionUpdate() {
        let helper = UpdateHelper()
        helper.pollUpdate(forced: true)
    }

    func testSubreddit() throws {
        XCTAssertTrue(true)
        
    }

}
