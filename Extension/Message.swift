//
//  Message.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 6/30/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum Message: CaseIterable {
    case begin
    case end
    case script
    case userKarmaFetchRequest, userKarmaSaveRequest, userKarmaFetchRequestResponse
    case threadCommentCountFetchRequest, threadCommentCountSaveRequest, threadCommentCountFetchRequestResponse

    var key: String {
        "\(self)"
    }

    static func fromString(_ string: String) -> Message? {
        Message.allCases.first { "\($0)" == string }
    }
}
