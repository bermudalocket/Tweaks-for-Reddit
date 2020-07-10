//
//  URL+queryParameters.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
