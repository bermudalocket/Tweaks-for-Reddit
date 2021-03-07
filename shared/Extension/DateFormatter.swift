//
//  DateFormatter.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

extension DateFormatter {
    static var relativeShort: DateFormatter {
        let formatter = DateFormatter()
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
