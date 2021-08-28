//
//  OAuthError.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public enum OAuthError: Error, Equatable {

    case badResponse(code: Int? = nil)
    case noToken

    case wrapping(message: String)

    case forbidden(token: String)
    case unauthorized

    case internalError

}
