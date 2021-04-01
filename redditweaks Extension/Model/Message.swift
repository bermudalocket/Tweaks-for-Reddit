//
//  Message.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/30/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum Message: CaseIterable {
    case begin
    case script

    var key: String {
        "\(self)"
    }

    static func fromString(_ string: String) -> Message? {
        Message.allCases.first { "\($0)" == string }
    }
}
