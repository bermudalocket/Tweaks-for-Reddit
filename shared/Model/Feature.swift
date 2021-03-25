//
// Created by bermudalocket on 1/25/20.
// Copyright (c) 2020 bermudalocket. All rights reserved.
//

import Foundation

struct Feature: Hashable, Comparable {

    /// User defaults key
    let key: String

    /// Description shown in popover
    let description: String

    /// Comparable alphabetically
    static func < (lhs: Feature, rhs: Feature) -> Bool {
        lhs.description < rhs.description
    }

}

extension Feature {

    static let features: [Feature] = [
        .showNewComments,
        .rememberUserVotes,
        .noChat,
        .showKarma,
        .customSubredditBar,
        .hideAds,
        .removePromotedPosts,
        .hideUsername,
        .collapseChildComments,
        .collapseAutoModerator,
        .hideNewRedditButton,
        .hideRedditPremiumBanner,
        .nsfwFilter,
        .noHappeningNowBanners,
        .oldRedditRedirect,
    ]

    static let showNewComments = Feature(key: "showNewComments", description: "Show number of new comments on visited threads")

    static let rememberUserVotes = Feature(key: "rememberUserVotes", description: "Remember up/downvoting users")

    static let oldRedditRedirect = Feature(key: "oldReddit", description: "Always use old.reddit.com")

    static let noHappeningNowBanners = Feature(key: "noHappeningNowBanners", description: "Remove Happening Now banners")

    static let noChat = Feature(key: "noChat", description: "Remove chat")

    static let showKarma = Feature(key: "showKarma", description: "Show karma")

    static let customSubredditBar = Feature(key: "customSubredditBar", description: "Custom subreddit bar")

    static let hideAds = Feature(key: "hideAds", description: "Hide ads")

    static let removePromotedPosts = Feature(key: "hidePromotedPosts", description: "Hide promoted posts")

    static let hideUsername = Feature(key: "hideUsername", description: "Remove username from user bar")

    static let collapseAutoModerator = Feature(key: "collapseAutoModerator", description: "Collapse AutoModerator")

    static let collapseChildComments = Feature(key: "collapseChildComments", description: "Collapse replies to top-level comments")

    static let hideRedditPremiumBanner = Feature(key: "hideRedditPremiumBanner", description: "Hide Reddit Premium banner")

    static let hideNewRedditButton = Feature(key: "hideNewRedditButton", description: "Hide New Reddit button")

    static let nsfwFilter = Feature(key: "nsfwFilter", description: "Filter NSFW posts")

}
