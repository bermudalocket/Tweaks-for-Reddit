//
//  OAuthResponse.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct OAuthResponse: Decodable, Equatable {
    let accessToken: String?
    let tokenType: String?
    let expire: Int?
    let scope: String?
    let refreshToken: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expire = "expires_in"
        case scope = "scope"
        case refreshToken = "refresh_token"
        case error = "error"
    }
}
