//
//  OAuthError.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public enum RedditError: Error, Equatable {

    case badResponse(code: Int? = nil)

    case noToken

    case wrapping(message: String)

    // indicates the token needs to be refreshed
    case unauthorized

    // indicates the snoovatar failed to download
    case downloadFailed

}
