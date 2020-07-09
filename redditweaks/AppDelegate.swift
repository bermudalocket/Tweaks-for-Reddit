//
//  AppDelegate.swift
//  redditweaks2
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Cocoa
import SwiftUI

let APP_ID = "com.bermudalocket.redditweaks"
let EXTENSION_ID = "com.bermudalocket.redditweaks-Extension"
let CLIENT_ID = "H6S3-yPygNPNfA"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let lastTokenExpiry = Reddit.mostRecentToken.expires
        let expired = lastTokenExpiry < Date()
        print("--------------------------------------------")
        print("Most recent token expiry: \(lastTokenExpiry)")
        print("Expired? \(expired ? "y" : "n") (\(Date()))")
        print("--------------------------------------------")
        if !expired {
            RedditAuthState.shared.accessToken = Reddit.mostRecentToken
        }

        let contentView = MainAppView()
            .environmentObject(OnboardingEnvironment())
            .environmentObject(RedditAuthState.shared)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 330),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeFirstResponder(nil)
        window.makeKeyAndOrderFront(self)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.compactMap { url in
            print("url in: \(url)")
            guard let params = url.queryParameters,
                  let code = params["code"],
                  let state = params["state"] else {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Error"
                alert.informativeText = "redditweaks encountered an error opening a rdtwks:// uri."
                alert.addButton(withTitle: "OK")
                alert.runModal()
                return nil
            }
            return RedditAuthResponse(error: false, code: code, state: state)
        }.forEach { response in
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "redditweaks.verify"), object: nil, userInfo: [
                "response": response
            ]))
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}

class EasyAlert: NSAlert {

    init(title: String, message: String) {
        super.init()
        super.messageText = title
        super.informativeText = message
        super.addButton(withTitle: "OK")
        super.runModal()
    }
}
