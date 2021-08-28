//
//  RedditPageType.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 6/30/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import Tweaks_for_Reddit_Popover

enum RedditPageType: CaseIterable {

    case feed, subreddit, post, user

    var features: [Feature] {
        let base: [Feature] = [.customSubredditBar, .hideJunk, .hideUsername, .noChat, .oldRedditRedirect, .showKarma, .showNewComments, .rememberUserVotes]
        switch self {
            case .feed:
                return base + [.autoExpandImages, .endlessScroll]

            case .post:
                return base + [.collapseAutoModerator, .collapseChildComments, .liveCommentPreview, .showEstimatedDownvotes]

            case .subreddit:
                return base + [.autoExpandImages, .endlessScroll]

            default:
                return base
        }
    }

    static func forURL(_ url: URL) -> RedditPageType? {
        let urlStr = url.absoluteString
        guard urlStr.contains("reddit") else {
            return nil
        }
        if urlStr.contains("/r/") {
            return urlStr.contains("/comments/") ? .post : .subreddit
        }
        if urlStr.contains("/user/") {
            return .user
        }
        return .feed
    }

}
