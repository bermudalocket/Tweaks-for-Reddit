//
//  SafariExtensionHandler.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Combine
import CoreData
import Foundation
import SafariServices
import Sentry
import SwiftUI
import TFRCore
import Tweaks_for_Reddit_Popover
import TFRPrivate

public class SafariExtensionHandler: SFSafariExtensionHandler {

    private let coreData = CoreDataService.shared

    override init() {
        SentrySDK.start { options in
            options.dsn = "https://33d9609f2a0a4d23b1b85dae218eefaf@o1178941.ingest.sentry.io/6291257"
            options.debug = false
            options.tracesSampleRate = 1.0
            options.sendDefaultPii = false
        }
    }

    public override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper {
            SentrySDK.capture(message: "Popover opened")
        }
    }

    private final func messageReceived(message: Message, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
        guard let userInfo = userInfo else {
            return
        }
        switch message {
            case .begin:
                let transaction = SentrySDK.startTransaction(name: "SafariExtensionHandler#messageReceived", operation: ".begin")
                guard let urlStr = userInfo["url"] as? String,
                      let url = URL(string: urlStr),
                      let pageType = RedditPageType.forURL(url)
                else {
                    transaction.finish(status: .invalidArgument)
                    return
                }
                if Feature.liveCommentPreview.isEnabled {
                    TFRPrivate.inject(into: page) // premium/paid features
                }
                pageType.features
                    .filter(\.isEnabled)
                    .map { buildJavascriptFunction(for: $0, on: pageType) }
                    .forEach(page.executeJavascript(_:))
                page.dispatchMessageToScript(message: .end)
                transaction.finish(status: .ok)

            case .threadCommentCountSaveRequest:
                let transaction = SentrySDK.startTransaction(name: "SafariExtensionHandler#messageReceived", operation: ".threadCommentCountSaveRequest")
                guard let thread = userInfo["thread"] as? String,
                      let countStr = userInfo["count"] as? String,
                      let count = Int(countStr) else {
                          transaction.finish(status: .invalidArgument)
                          return
                }
                coreData.saveCommentCount(for: thread, count: count)
                transaction.finish(status: .ok)

            case .threadCommentCountFetchRequest:
                let transaction = SentrySDK.startTransaction(name: "SafariExtensionHandler#messageReceived", operation: ".threadCommentCountFetchRequest")
                guard let thread = userInfo["thread"] as? String else {
                    transaction.finish(status: .invalidArgument)
                    return
                }
                let count = coreData.commentCount(for: thread) ?? -1
                page.dispatchMessageToScript(message: .threadCommentCountFetchRequestResponse, userInfo: [
                    "thread": thread,
                    "count": count
                ])
                transaction.finish(status: .ok)

            case .userKarmaFetchRequest:
                let transaction = SentrySDK.startTransaction(name: "SafariExtensionHandler#messageReceived", operation: ".userKarmaFetchRequest")
                guard let user = userInfo["user"] as? String,
                      let karma = coreData.userKarma(for: user),
                      karma != 0 else {
                        transaction.finish(status: .invalidArgument)
                        return
                }
                page.dispatchMessageToScript(message: .userKarmaFetchRequestResponse, userInfo: [
                    "user": user,
                    "karma": karma
                ])
                transaction.finish(status: .ok)

            case .userKarmaSaveRequest:
                let transaction = SentrySDK.startTransaction(name: "SafariExtensionHandler#messageReceived", operation: ".userKarmaSaveRequest")
                guard let user = userInfo["user"] as? String,
                      let karma = userInfo["karma"] as? Int else {
                        transaction.finish(status: .invalidArgument)
                        return
                }
                coreData.saveUserKarma(for: user, karma: karma)
                transaction.finish(status: .ok)

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
                let subs = coreData.favoriteSubreddits
                        .compactMap(\.name)
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
    public override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        log("[Ext Msg] \(messageName)")
        guard let message = Message.fromString(messageName) else {
            print("ERROR: couldn't get Message object from key \(messageName)")
            return
        }
        messageReceived(message: message, from: page, userInfo: userInfo)
    }

}

extension SFSafariPage {

    func dispatchMessageToScript(message: Message, userInfo: [String: Any]? = nil) {
        dispatchMessageToScript(withName: message.key, userInfo: userInfo)
    }

    func executeJavascript(_ javascript: String) {
        dispatchMessageToScript(message: .script, userInfo: [ "function": javascript ])
    }

}
