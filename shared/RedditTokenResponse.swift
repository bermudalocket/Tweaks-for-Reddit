//
//  RedditTokenResponse.swift
//  redditweaks
//  5.0
//  10.16
//
//  Created by bermudalocket on 6/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

struct RedditTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let lifetime: Int
    let scope: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case lifetime = "expires_in"
        case refreshToken = "refresh_token"

        case scope
    }
}

struct RedditRefreshTokenResponse: Codable {
    let accessToken: String
    let scope: String
    let tokenType: String
    let lifetime: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case lifetime = "expires_in"

        case scope
    }
}
