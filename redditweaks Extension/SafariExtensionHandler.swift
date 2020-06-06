//
//  Model.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/2/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Cocoa
import Foundation
import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    static let shared = SafariExtensionHandler()

    let model = Model()

    lazy var viewController = SafariExtensionViewController(model: self.model)

    override func popoverViewController() -> SFSafariExtensionViewController {
        self.viewController
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String: Any]?) {
        if messageName == "redditweaks.onDomLoaded" {
            self.model.features
                .filter { $0.value }
                .map { $0.key }
                .forEach(self.sendScriptToSafariPage(_:))
        }
    }

    internal func sendScriptToSafariPage(_ feature: Feature) {
        SFSafariApplication.getActiveWindow { window in
            guard let window = window else {
                NSLog("Couldn't send script to page b/c getActiveWindow was nil")
                return
            }
            window.getActiveTab { tab in
                guard let tab = tab else {
                    NSLog("Couldn't send script to page b/c getActiveTab was nil")
                    return
                }
                tab.getActivePage { page in
                    guard let page = page else {
                        NSLog("Couldn't send script to page b/c getActivePage was nil")
                        return
                    }
                    guard var script = self.model.features[feature]! ? feature.javascript : feature.javascriptOff else {
                        NSLog("Couldn't send script to page b/c the script itself was nil")
                        return
                    }
                    if feature.name == "customSubredditBar",
                            let subs = UserDefaults.standard.string(forKey: "customSubsArray"),
                            let disabled = UserDefaults.standard.array(forKey: "disabledShortcuts") {
                        let disabledShortcuts = disabled.compactMap { "\($0 as? Int)" }.joined(separator: ",")
                        script = script.replacingOccurrences(of: "%SUBS%", with: subs)
                        script = script.replacingOccurrences(of: "%DISABLEDSHORTCUTS%", with: disabledShortcuts)
                    }
                    page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [
                        "script": script
                    ])
                }
            }
        }
    }

}
