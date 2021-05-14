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

    /// Whether or not this is an in-app purchase
    let premium: Bool

    /// A string to display to the user as a tooltip on hover
    let help: String

    init(key: String, description: String, premium: Bool = false, help: String = "") {
        self.key = key
        self.description = description
        self.premium = premium
        self.help = help
    }

    var isEnabled: Bool {
        Redditweaks.defaults.bool(forKey: key)
    }

    /// Comparable alphabetically
    static func < (lhs: Feature, rhs: Feature) -> Bool {
        lhs.description < rhs.description
    }

}

extension Feature {

    static let features: [Feature] = [
        .endlessScroll,
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
        .noHappeningNowBanners,
        .oldRedditRedirect,
    ]

    // in-app purchase
    static let liveCommentPreview = Feature(key: "liveCommentPreview",
                                            description: "Preview reply in markdown",
                                            premium: true)

    static let endlessScroll = Feature(key: "endlessScroll",
                                       description: "Endless scrolling",
                                       help: "Tweaks for Reddit will automatically load the next 25 posts as you near the bottom of the page")

    static let showNewComments = Feature(key: "showNewComments",
                                         description: "Track new comments on visited posts",
                                         help: "Tweaks for Reddit will show the number of new comments made on threads since you visited.")

    static let rememberUserVotes = Feature(key: "rememberUserVotes",
                                           description: "Remember up/downvoting users",
                                           help: "Tweaks for Reddit will remember when you upvote and downvote users and display their net vote count (if not 0) on their posts and comments")

    static let oldRedditRedirect = Feature(key: "oldReddit", description: "Always use old.reddit.com",
                                           help: "Tweaks for Reddit will attempt to bring you to the Old Reddit version of a page if it detects New Reddit")

    static let noHappeningNowBanners = Feature(key: "noHappeningNowBanners",
                                               description: "Remove Happening Now banners")

    static let noChat = Feature(key: "noChat", description: "Remove chat")

    static let showKarma = Feature(key: "showKarma", description: "Show comment and post karma in user bar",
                                   help: "Tweaks for Reddit will parse your profile to include your comment and post karma in the user bar")

    static let customSubredditBar = Feature(key: "customSubredditBar", description: "Favorite subreddits bar",
                                            help: "Tweaks for Reddit will replace the subreddit bar at the top of every page with a list of your favorite subreddits")

    static let hideAds = Feature(key: "hideAds", description: "Hide ads")

    static let removePromotedPosts = Feature(key: "hidePromotedPosts", description: "Hide promoted posts")

    static let hideUsername = Feature(key: "hideUsername", description: "Remove username from user bar",
                                      help: "Tweaks for Reddit will help you guard your privacy from peering eyes by removing your username from the user bar")

    static let collapseAutoModerator = Feature(key: "collapseAutoModerator", description: "Collapse AutoModerator", help: "Tweaks for Reddit will collapse all comments made by an AutoModerator account")

    static let collapseChildComments = Feature(key: "collapseChildComments", description: "Collapse top-level replies", help: "Tweaks for Reddit will collapse subcomments on posts")

    static let hideRedditPremiumBanner = Feature(key: "hideRedditPremiumBanner", description: "Hide Reddit Premium banner")

    static let hideNewRedditButton = Feature(key: "hideNewRedditButton", description: "Hide New Reddit button")

}
