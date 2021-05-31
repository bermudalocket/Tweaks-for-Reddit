//
//  SafariExtensionHandler.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import CoreData
import Foundation
import SafariServices
import SwiftUI

final class SafariExtensionHandler: SFSafariExtensionHandler {
class SafariExtensionHandler: SFSafariExtensionHandler {

    private let injectedPersistenceController: PersistenceController

    override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper()
    }

    override init() {
        self.injectedPersistenceController = .shared
        super.init()
    }

    init(persistenceController: PersistenceController = .shared) {
        self.injectedPersistenceController = persistenceController
        super.init()
    }

    final func messageReceived(message: Message, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
        guard let userInfo = userInfo else {
            return
        }
        switch message {
            case .begin:
                guard let urlStr = userInfo["url"] as? String,
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
                    .map { buildJavascriptFunction(for: $0, on: pageType) }
                    .forEach(page.executeJavascript(_:))

            case .threadCommentCountSaveRequest:
                guard let thread = userInfo["thread"] as? String,
                      let countStr = userInfo["count"] as? String,
                      let count = Int(countStr) else {
                    return
                }
                injectedPersistenceController.saveCommentCount(for: thread, count: count)

            case .threadCommentCountFetchRequest:
                guard let thread = userInfo["thread"] as? String else {
                    return
                }
                let count = injectedPersistenceController.commentCount(for: thread) ?? -1
                page.dispatchMessageToScript(message: .threadCommentCountFetchRequestResponse, userInfo: [
                    "thread": thread,
                    "count": count
                ])

            case .userKarmaFetchRequest:
                guard let user = userInfo["user"] as? String,
                      let karma = injectedPersistenceController.userKarma(for: user),
                      karma != 0 else {
                    return
                }
                page.dispatchMessageToScript(message: .userKarmaFetchRequestResponse, userInfo: [
                    "user": user,
                    "karma": karma
                ])

            case .userKarmaSaveRequest:
                guard let user = userInfo["user"] as? String,
                      let karma = userInfo["karma"] as? Int else {
                    return
                }
                injectedPersistenceController.saveUserKarma(for: user, karma: karma)

            default:
                print("Received message not meant for this handler: \(message) \(userInfo)")
        }
    }

    final func buildJavascriptFunction(for feature: Feature, on pageType: RedditPageType) -> String {
        switch feature {
            case .showNewComments:
                switch pageType {
                    case .feed, .subreddit, .user:
                        return "showNewComments('parseAndLoad')"

                    case .post:
                        return "showNewComments('parseAndSave')"
                }

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
