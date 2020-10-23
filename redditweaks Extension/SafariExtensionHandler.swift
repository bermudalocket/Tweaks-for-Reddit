//
//  SafariExtensionHandler.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation
import SafariServices

enum Message: CaseIterable {
    case ADD_FAVORITE_SUB
    case DEBUG
    case KEEP_ALIVE
    case ON_DOM_LOADED
    case PING
    case REMOVE_FAVORITE_SUB
    case SCRIPT

    var key: String {
        "\(self)".lowercased()
    }

    static func fromKey(_ key: String) -> Message? {
        Message.allCases.first { "\($0)".lowercased() == key }
    }
}

extension SFSafariPage {
    func dispatchMessageToScript(message: Message, userInfo: [String: Any]? = nil) {
        dispatchMessageToScript(withName: message.key, userInfo: userInfo)
    }
}

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper()
    }

    #if DEBUG
    override func page(_ page: SFSafariPage, willNavigateTo url: URL?) {
        page.dispatchMessageToScript(message: .KEEP_ALIVE)
    }
    #endif

    /**
     Receives a wrapped message from the extension.

     - Parameter message: The type of message being received.
     - Parameter page: The page from which the message was sent.
     - Parameter userInfo: An optional dictionary containing extra information relevant to the message.
     */
    func messageReceived(message: Message, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
        switch message {
            case .ON_DOM_LOADED:
                Feature.features
                    .filter { Redditweaks.defaults.bool(forKey: $0.name) }
                    .forEach {
                        var script = $0.javascript
                        if $0.name == "customSubredditBar" {
                            let favSubsList = Redditweaks.favoriteSubreddits.map { "\"\($0)\"" }.joined(separator: ",")
                            script = script.replacingOccurrences(of: "%SUBS%", with: favSubsList)
                        }
                        page.dispatchMessageToScript(message: .SCRIPT, userInfo: [ "name": $0.name, "script": script ])
                    }

            case .ADD_FAVORITE_SUB:
                guard let userInfo = userInfo, let sub = userInfo["subreddit"] as? String else {
                    return
                }
                Redditweaks.addFavoriteSubreddit(sub)
                page.dispatchMessageToScript(message: .DEBUG, userInfo: ["info": "added favorite \(sub)"])

            case .REMOVE_FAVORITE_SUB:
                guard let userInfo = userInfo, let sub = userInfo["subreddit"] as? String else {
                    return
                }
                Redditweaks.removeFavoriteSubreddit(sub)
                page.dispatchMessageToScript(message: .DEBUG, userInfo: ["info": "removed favorite \(sub)"])

            default: print("Received a weird message: \(message)")
        }
    }

    /**
     Converts a vanilla Safari extension message into an enumerable one and passes it along.
     */
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        guard let message = Message.fromKey(messageName) else {
            print("ERROR: couldn't get Message object from key \(messageName)")
            return
        }
        messageReceived(message: message, from: page, userInfo: userInfo)
    }

}
