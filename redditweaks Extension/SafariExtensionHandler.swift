//
//  SafariExtensionHandler.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import CoreData
import Foundation
import SafariServices
import SwiftUI

final class SafariExtensionHandler: SFSafariExtensionHandler {

    override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper()
    }

    final func messageReceived(message: Message, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
        switch message {
            case .begin:
                guard let userInfo = userInfo,
                      let urlStr = userInfo["url"] as? String,
                      let url = URL(string: urlStr),
                      let pageType = RedditPageType.forURL(url)
                else {
                    return
                }
                if IAPHelper.shared.didPurchaseLiveCommentPreviews {
                    NoCommit.inject(into: page) // premium/paid features
                }
                pageType.features
                    .filter(\.isEnabled)
                    .map(buildJavascriptFunction(for:))
                    .forEach(page.executeJavascript(_:))

            default:
                print("Received a weird message: \(message)")
        }
    }

    final func buildJavascriptFunction(for feature: Feature) -> String {
        switch feature {
            case .customSubredditBar:
                let subs = PersistenceController.shared
                        .favoriteSubreddits
                        .compactMap({ "'\($0)'" })
                        .joined(separator: ",")
                return "customSubredditBar([\(subs)])"

            default:
                return feature.key + "()"
        }
    }

    /**
     Converts a vanilla Safari extension message into an enumerable one and passes it along.
     */
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        guard let message = Message.fromString(messageName) else {
            print("ERROR: couldn't get Message object from key \(messageName)")
            return
        }
        messageReceived(message: message, from: page, userInfo: userInfo)
    }

}
