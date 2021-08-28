//
//  OAuthResponse.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

struct OAuthResponse: Decodable, Equatable {
    let accessToken: String?
    let refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}
