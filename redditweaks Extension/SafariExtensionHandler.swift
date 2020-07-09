//
//  SafariExtensionHandler.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import SafariServices

class Redditweaks {

    public static let defaults = UserDefaults(suiteName: "com.bermudalocket.redditweaks")!

    public static let favoriteSubredditsPublisher = CurrentValueSubject<[String], Never>(favoriteSubreddits)

    public static var favoriteSubreddits: [String] {
        get {
            guard let favorites = defaults.array(forKey: "favoriteSubreddits") as? [String] else {
                return []
            }
            return favorites
        }
        set {
            favoriteSubredditsPublisher.send(newValue)
            defaults.setValue(newValue, forKey: "favoriteSubreddits")
        }
    }

    public static func addFavoriteSubreddit(_ favoriteSubreddit: inout String) {
        if favoriteSubreddit.starts(with: "r/") {
            favoriteSubreddit.removeFirst(2)
        }
        favoriteSubreddits.append(favoriteSubreddit)
    }

    public static func removeFavoriteSubreddit(_ favoriteSubreddit: String) {
        favoriteSubreddits.removeAll {
            $0 == favoriteSubreddit
        }
    }

}

class SafariExtensionHandler: SFSafariExtensionHandler {

    static let shared = SafariExtensionHandler()

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
                        script = $0.javascript.replacingOccurrences(of: "%SUBS%", with:
                                                                      Redditweaks.favoriteSubreddits
                                                                      .map { "\"\($0)\"" }
                                                                      .joined(separator: ",")
                        )
                    }
                    page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [ "script": script ])
                }
        }
    }

    func sendScriptToSafariPage(_ feature: Feature) {
        SFSafariApplication.getAllWindows { windows in
            windows.forEach { window in
                window.getAllTabs { tabs in
                    tabs.forEach { tab in
                        tab.getActivePage { page in
                            guard let page = page else {
                                NSLog("Couldn't send script to page b/c getActivePage was nil")
                                return
                            }
                            guard var script = Redditweaks.defaults.bool(forKey: feature.name) ? feature.javascript : feature.javascriptOff else {
                                NSLog("Couldn't send script to page b/c the script itself was nil")
                                return
                            }
                            if feature.name == "customSubredditBar" {
                                script = script.replacingOccurrences(of: "%SUBS%", with: Redditweaks.favoriteSubreddits.joined(separator: ", "))
                            }
                            page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [ "script": script ])
                        }
                    }
                }
            }
        }
    }

}
