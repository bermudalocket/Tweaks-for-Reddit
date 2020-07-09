//
//  Data+prettyPrinted.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
