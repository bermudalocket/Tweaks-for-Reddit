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
    case addFavoriteSub
    case begin
    case domLoaded
    case removeFavoriteSub
    case script

    var key: String {
        "\(self)".lowercased()
    }

    static func fromString(_ string: String) -> Message? {
        Message.allCases.first { "\($0)" == string }
    }
}

extension SFSafariPage {
    func dispatchMessageToScript(message: Message, userInfo: [String: Any]? = nil) {
        dispatchMessageToScript(withName: message.key, userInfo: userInfo)
    }
}

enum RedditPageType {
    case feed, subreddit, post, user

    var features: [Feature] {
        let base: [Feature] = [.customSubredditBar, .hideNewRedditButton, .hideUsername, .noChat, .oldRedditRedirect, .showKarma, .showNewComments, .rememberUserVotes]
        switch self {
            case .feed:
                return base + [.hideAds, .hideRedditPremiumBanner, .noHappeningNowBanners, .nsfwFilter, .removePromotedPosts]

            case .post:
                return base + [.collapseAutoModerator, .collapseChildComments]

            case .subreddit:
                return base + [.nsfwFilter]

            case .user:
                return base
        }
    }

    public static func forURL(_ url: URL) -> RedditPageType {
        let urlStr = url.absoluteString
        if urlStr.contains("/r/") {
            return urlStr.contains("/comments/") ? .post : .subreddit
        }
        if urlStr.contains("/user/") {
            return .user
        }
        return .feed
    }
}

class SafariExtensionHandler: SFSafariExtensionHandler {

    static let viewWrapper = PopoverViewWrapper()

    override func popoverViewController() -> SFSafariExtensionViewController {
        SafariExtensionHandler.viewWrapper
    }

    /**
     Receives a wrapped message from the extension.

     - Parameter message: The type of message being received.
     - Parameter page: The page from which the message was sent.
     - Parameter userInfo: An optional dictionary containing extra information relevant to the message.
     */
    func messageReceived(message: Message, from page: SFSafariPage, userInfo: [String: Any]? = nil) {
        let state = AppState()
        switch message {
            case .begin:
                guard let userInfo = userInfo,
                      let urlStr = userInfo["url"] as? String,
                      let url = URL(string: urlStr)
                else {
                    return
                }
                let features = RedditPageType.forURL(url)
                    .features
                    .filter { feature in
                        Redditweaks.defaults.bool(forKey: feature.key)
                    }
                    .map { feature -> String in
                        switch feature {
                            case .customSubredditBar:
                                let subs = state.favoriteSubreddits.map { "'\($0)'" }.joined(separator: ",")
                                return "customSubredditBar([\(subs)])"

                            default:
                                return feature.key + "()"
                        }
                    }
                page.dispatchMessageToScript(message: .script, userInfo: [
                    "functions": features
                ])

            case .addFavoriteSub:
                guard let userInfo = userInfo, let sub = userInfo["subreddit"] as? String else {
                    return
                }
                state.addFavoriteSubreddit(subreddit: sub)

            case .removeFavoriteSub:
                guard let userInfo = userInfo, let sub = userInfo["subreddit"] as? String else {
                    return
                }
                state.removeFavoriteSubreddit(subreddit: sub)

            default:
                print("Received a weird message: \(message)")
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
