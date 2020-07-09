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

    private var cancellables = [AnyCancellable]()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let expectation = self.expectation(description: "karma")
        Reddit.countKarma().sink(receiveCompletion: { completion in
            switch completion {
                case .failure(let error):
                    XCTFail(error.localizedDescription)
                default:
                    break
            }
        }, receiveValue: { karma in
            let total = karma.reduce(into: 0) { totalKarma, subreddit in
                totalKarma += subreddit.comment_karma
            }
            XCTAssert(total > 6200)
            expectation.fulfill()
        }).store(in: &cancellables)
        self.waitForExpectations(timeout: 5000) { completion in
            if let error = completion {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
