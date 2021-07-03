//
//  Tokens.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct Tokens: Decodable, Equatable {
    public let accessToken: String?
    public let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

extension Tokens {
    static let empty = Tokens(accessToken: nil, refreshToken: nil)
}
