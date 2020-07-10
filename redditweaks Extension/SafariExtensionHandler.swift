//
//  SafariExtensionHandler.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func popoverViewController() -> SFSafariExtensionViewController {
        PopoverViewWrapper()
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        if messageName == "redditweaks.onDomLoaded" {
            Feature.features
                .filter { Redditweaks.defaults.bool(forKey: $0.name) }
                .forEach {
                    var script = $0.javascript
                    if $0.name == "customSubredditBar" {
                        let favSubsList = Redditweaks.favoriteSubreddits.map { "\"\($0)\"" }.joined(separator: ",")
                        script = $0.javascript.replacingOccurrences(of: "%SUBS%", with: favSubsList)
                    }
                    page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [ "script": script ])
                }
        }
    }

}
