//
//  URL+queryParameters.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        var url = self.absoluteString
        guard let qmark = url.lastIndex(of: "?") else {
            return nil
        }
        url.removeSubrange(url.indices.startIndex...qmark)

        var queryParameters = [String: String]()
        for entry in url.split(separator: "&") {
            let kv = entry.split(separator: "=")
            guard let key = kv.first, let value = kv.last else {
                continue
            }
            queryParameters[String(key)] = String(value)
        }

        return queryParameters
    }
}
