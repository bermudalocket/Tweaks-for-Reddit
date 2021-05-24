//
//  RedditPageType.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/30/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Foundation

enum RedditPageType: CaseIterable {

    case feed, subreddit, post, user

    var features: [Feature] {
        let base: [Feature] = [.customSubredditBar, .hideNewRedditButton, .hideRedditPremiumBanner, .hideUsername, .noChat, .oldRedditRedirect, .showKarma, .showNewComments, .rememberUserVotes]
        switch self {
            case .feed:
                return base + [.autoExpandImages, .hideAds, .hideHappeningNowBanners, .removePromotedPosts, .endlessScroll]

            case .post:
                return base + [.collapseAutoModerator, .collapseChildComments, .liveCommentPreview]

            case .subreddit:
                return base + [.autoExpandImages, .endlessScroll]

            default:
                return base
        }
    }

    public static func forURL(_ url: URL) -> RedditPageType? {
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
