//
//  ExtensionError.swift
//  ExtensionError
//
//  Created by Michael Rippe on 8/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum ExtensionError: Error {
    case favoriteSubredditInvalid
    case favoriteSubredditRedundant
    case didNotPurchaseLiveCommentPreviews
}
