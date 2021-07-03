//
//  OAuthError.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public enum OAuthError: Error, Equatable {

    case badResponse(code: Int? = nil)
    case noToken
    case noRefreshToken
    case refreshFailure
    case unknownUpstreamError

    case wrapping(message: String)

    case forbidden(token: String)
    case unauthorized

    case alreadyAuthorizing
    case internalError

    case badState
    case badCode

    var localizedDescription: String {
        switch self {
            case .refreshFailure:
                return "We couldn't get a new access token from Reddit. Try reauthorizing in the main Tweaks for Reddit app."

            default:
                return "\(self)"
        }
    }

}
