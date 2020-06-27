//
//  AppDelegate.swift
//  redditweaks2
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import Cocoa
import SwiftUI

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

struct RedditAuthResponse {
    let error: Bool
    let code: String
    let state: String
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = MainAppView()
            .environmentObject(OnboardingEnvironment())

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 330),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.filter { url in
            url.absoluteString.starts(with: "rdtwks://")
        }.compactMap { url -> RedditAuthResponse in
            guard let params = url.queryParameters,
                  let code = params["code"],
                  let state = params["state"] else {
                print("Error ----------------------------")
                return RedditAuthResponse(error: true, code: "", state: "")
            }
            print("code ===== \(code)")
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
