//
// Created by bermudalocket on 1/25/20.
// Copyright (c) 2020 bermudalocket. All rights reserved.
//

import Foundation

class Feature {

    static let features: [Feature] = [
        Feature.hideAds,
        Feature.removePromotedPosts,
        Feature.hideUsername,
        Feature.collapseChildComments,
        Feature.collapseAutoModerator,
        Feature.hideNewRedditButton,
        Feature.hideRedditPremiumBanner,
        Feature.nsfwFilter
    ]

    static func fromDescription(_ description: String) -> Feature? {
        for feature in features {
            if feature.description == description {
                return feature
            }
        }
        return nil
    }

    let name: String

    let description: String

    let javascript: String

    let javascriptOff: String?

    init(name: String, description: String, javascript: String, javascriptOff: String? = nil) {
        self.name = name
        self.description = description
        self.javascript = javascript
        self.javascriptOff = javascriptOff
    }

    static let hideAds = Feature(
        name: "hideAds",
        description: "Hide ads",
        javascript: """
            $('.ad-container, .ad-container, #ad_1').each(function() {
                $(this).remove();
                safari.extension.dispatchMessage("redditweaks.incrementCounter");
            });
        """,
        javascriptOff: """
            $('.ad-container, .ad-container ').each(function() {
                $(this).show();
                safari.extension.dispatchMessage("redditweaks.decrementCounter");
            });
        """
    )

    static let removePromotedPosts = Feature(
        name: "removePromotedPosts",
        description: "Hide promoted posts",
        javascript: """
            $('.promoted').each(function() {
                $(this).hide();
                safari.extension.dispatchMessage("redditweaks.incrementCounter");
            });
        """,
        javascriptOff: """
            $('.promoted').each(function() {
                $(this).show();
                safari.extension.dispatchMessage("redditweaks.decrementCounter");
            });
        """
    )

    static let hideUsername = Feature(
        name: "hideUsername",
        description: "Remove username from user bar",
        javascript: """
            let stuff = $('#header-bottom-right span').html();
            localStorage.setItem('redditweaks.usernameinfo', stuff);
            $('#header-bottom-right span').html('');
        """,
        javascriptOff: """
            $('#header-bottom-right span').first().html(localStorage.getItem('redditweaks.usernameinfo'));
        """
    )

    static let collapseAutoModerator = Feature(
        name: "collapseAutoModerator",
        description: "Collapse AutoModerator",
        javascript: """
            $('div[data-author=AutoModerator]').each(function() {
                $(this).removeClass('noncollapsed');
                $(this).addClass('collapsed');
                $(this).find('.expand').html('[+]');
            });
        """,
        javascriptOff: """
            $('div[data-author=AutoModerator]').each(function() {
                $(this).removeClass('collapsed');
                $(this).addClass('noncollapsed');
                $(this).find('.expand').html('[-]');
            });
        """
    )

    static let collapseChildComments = Feature(
            name: "collapseChildComments",
            description: "Collapse replies to top-level comments",
            javascript: """
                        $('.comment .noncollapsed').each(function() {
                            $(this).removeClass('noncollapsed');
                            $(this).addClass('collapsed');
                            $(this).find('.expand').html('[+]');
                        });
                        """,
            javascriptOff: """
                        $('.comment .collapsed').each(function() {
                            $(this).removeClass('collapsed');
                            $(this).addClass('noncollapsed');
                            $(this).find('.expand').html('[-]');
                        });
                        """)

    static let hideRedditPremiumBanner = Feature(
        name: "hideRedditPremiumBanner",
        description: "Hide Reddit Premium banner",
        javascript: "$('.premium-banner-outer').hide();",
        javascriptOff: "$('.premium-banner-outer').show();");

    static let hideNewRedditButton = Feature(
        name: "hideNewRedditButton",
        description: "Hide New Reddit button",
        javascript: "$('.redesign-beta-optin').hide();",
        javascriptOff: "$('.redesign-beta-optin').show();")

    static let nsfwFilter = Feature(
        name: "nsfwFilter",
        description: "Filter NSFW posts",
        javascript: """
                    $('.over18').each(function() {
                        $(this).hide();
                        safari.extension.dispatchMessage("redditweaks.incrementCounter");
                    })
                    """,
        javascriptOff: """
                    $('.over18').each(function() {
                        $(this).show();
                        safari.extension.dispatchMessage("redditweaks.decrementCounter");
                    })
                    """)

}
