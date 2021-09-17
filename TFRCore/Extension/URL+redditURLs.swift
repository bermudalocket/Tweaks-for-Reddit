//
//  URL+redditURLs.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

extension URL {

    static let accessToken = Self(string: "https://www.reddit.com/api/v1/access_token")!
    static let refreshToken = accessToken

    

}
