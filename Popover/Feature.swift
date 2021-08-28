//
// Created by Michael Rippe on 1/25/20.
// Copyright (c) 2020 Michael Rippe. All rights reserved.
//

import Foundation
import Tweaks_for_Reddit_Core

public struct Feature: Hashable, Comparable {

    /// User defaults key
    public let key: String

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

    public var isEnabled: Bool {
        TweaksForReddit.defaults.bool(forKey: key)
    }

    /// Comparable alphabetically
    public static func < (lhs: Feature, rhs: Feature) -> Bool {
        lhs.description < rhs.description
    }

}

extension Feature {

    public static let features: [Feature] = [
        .showEstimatedDownvotes,
        .autoExpandImages,
        .endlessScroll,
        .showNewComments,
        .rememberUserVotes,
        .noChat,
        .showKarma,
        .customSubredditBar,
        .hideUsername,
        .collapseChildComments,
        .collapseAutoModerator,
        .oldRedditRedirect,
        .hideJunk
    ]

    // in-app purchase
    public static let liveCommentPreview = Feature(
        key: "liveCommentPreview",
        description: "Preview reply in markdown",
        premium: true
    )

    public static let hideJunk = Feature(
        key: "hideJunk",
        description: "Hide junk",
        help: "Hides visual junk"
    )

    public static let showEstimatedDownvotes = Feature(
        key: "showEstimatedDownvotes",
        description: "Show estimated downvotes",
        help: "When viewing a post, Tweaks for Reddit will estimate and display the number of downvotes"
    )

    public static let autoExpandImages = Feature(
        key: "autoExpandImages",
        description: "Automatically expand images",
        help: "Tweaks for Reddit will automatically expand all expandable image posts"
    )

    public static let endlessScroll = Feature(
        key: "endlessScroll",
        description: "Endless scrolling",
        help: "Tweaks for Reddit will automatically load the next 25 posts as you near the bottom of the page"
    )

    public static let showNewComments = Feature(
        key: "showNewComments",
        description: "Track new comments on visited posts",
        help: "Tweaks for Reddit will show the number of new comments made on threads since you visited."
    )

    public static let rememberUserVotes = Feature(
        key: "rememberUserVotes",
        description: "Remember up/downvoting users",
        help: "Tweaks for Reddit will remember when you upvote and downvote users and display their net vote count (if not 0) on their posts and comments"
    )

    public static let oldRedditRedirect = Feature(
        key: "oldReddit",
        description: "Always use old.reddit.com",
        help: "Tweaks for Reddit will attempt to bring you to the Old Reddit version of a page if it detects New Reddit"
    )

    public static let noChat = Feature(
        key: "noChat",
        description: "Remove chat"
    )

    public static let showKarma = Feature(
        key: "showKarma",
        description: "Show comment and post karma in user bar",
        help: "Tweaks for Reddit will parse your profile to include your comment and post karma in the user bar"
    )

    public static let customSubredditBar = Feature(
        key: "customSubredditBar",
        description: "Favorite subreddits bar",
        help: "Tweaks for Reddit will replace the subreddit bar at the top of every page with a list of your favorite subreddits"
    )

    public static let hideUsername = Feature(
        key: "hideUsername",
        description: "Remove username from user bar",
        help: "Tweaks for Reddit will help you guard your privacy from peering eyes by removing your username from the user bar"
    )

    public static let collapseAutoModerator = Feature(
        key: "collapseAutoModerator",
        description: "Collapse AutoModerator",
        help: "Tweaks for Reddit will collapse all comments made by an AutoModerator account"
    )

    public static let collapseChildComments = Feature(
        key: "collapseChildComments",
        description: "Collapse top-level replies",
        help: "Tweaks for Reddit will collapse subcomments on posts"
    )

}
