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

    private var cancellables = Set<AnyCancellable>()

    func testCheckSubredditValidity() {
        Redditweaks.verifySubredditExists("abcdefgrgrgrg")
            .sink { completion in

            } receiveValue: { value in
                
            }
            .store(in: &cancellables)
    }

}
