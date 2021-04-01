//
//  SFSafariPage+redditweaks.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/30/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SafariServices

extension SFSafariPage {

    func dispatchMessageToScript(message: Message, userInfo: [String: Any]? = nil) {
        dispatchMessageToScript(withName: message.key, userInfo: userInfo)
    }

    func executeJavascript(_ javascript: String) {
        dispatchMessageToScript(message: .script, userInfo: [ "function": javascript ])
    }
    
}
