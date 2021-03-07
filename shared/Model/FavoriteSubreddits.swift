//
//  FavoriteSubreddits.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

typealias FavoriteSubreddits = [String]

extension FavoriteSubreddits: RawRepresentable {

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(FavoriteSubreddits.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
