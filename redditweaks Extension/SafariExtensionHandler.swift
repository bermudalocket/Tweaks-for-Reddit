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

    let persistence: PersistenceController

    override init() {
        self.persistence = PersistenceController.shared
        super.init()
    }

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper()
    }

    /**
     Receives a wrapped message from the extension.

     - Parameter message: The type of message being received.
     - Parameter page: The page from which the message was sent.
     - Parameter userInfo: An optional dictionary containing extra information relevant to the message.
     */
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
                guard let subs = self.persistence
                        .getFavoriteSubreddits()?
                        .compactMap({ "'\($0)'" })
                        .joined(separator: ",")
                else {
                    return ""
                }
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
