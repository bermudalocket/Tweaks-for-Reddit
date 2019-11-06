//
//  SafariExtensionHandler.swift
//  redditweaks2 Extension
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        switch messageName {
            case "redditweaks.domLoaded":
                SafariExtensionViewController.shared.count = 0
                SafariExtensionViewController.shared.updateFilter()
            case "redditweaks.incrementNSFWCounter":
                SafariExtensionViewController.shared.count += 1
            default:
                return
        }
    }

    override func popoverViewController() -> SFSafariExtensionViewController {
        return SafariExtensionViewController.shared
    }

}
