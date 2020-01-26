//
//  SafariExtensionHandler.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import SafariServices
import SwiftUI

class SafariExtensionHandler: SFSafariExtensionHandler {

    @objc static func sendScriptToSafariPage(_ script: String) {
        SFSafariApplication.getActiveWindow { window in
            window?.getActiveTab { tab in
                tab?.getActivePage { page in
                    guard let page = page else {
                        NSLog("Failed to fetch page for script \(script)")
                        return
                    }
                    page.dispatchMessageToScript(withName: "redditweaks.script", userInfo: [
                        "script": script
                    ])
                }
            }
        }
    }

    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping (Bool, String) -> Void) {
        let numberOfFilteredPosts = SafariExtensionViewController.shared.numberOfFilteredPosts
        let badge = numberOfFilteredPosts == 0 ? "" : "\(numberOfFilteredPosts)"
        validationHandler(true, badge)
    }

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        if messageName == "redditweaks.incrementCounter" {
            SafariExtensionViewController.shared.numberOfFilteredPosts += 1
        } else if messageName == "redditweaks.decrementCounter" {
            SafariExtensionViewController.shared.numberOfFilteredPosts -= 1
        } else if messageName == "redditweaks.resetCounter" {
            SafariExtensionViewController.shared.numberOfFilteredPosts = 0
        } else if messageName == "redditweaks.onDomLoaded" {
            page.getPropertiesWithCompletionHandler { properties in
                guard let properties = properties, let url = properties.url else {
                    return
                }
                SafariExtensionViewController.shared.pageLoaded(url)
            }
        }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        SafariExtensionViewController.shared
    }

}
