//
//  ViewController.swift
//  redditweaks2
//
//  Created by bermudalocket on 10/21/19.
//  Copyright © 2019 bermudalocket. All rights reserved.
//

import SwiftUI
import StoreKit

@main
struct RedditweaksApp: App {

    @NSApplicationDelegateAdaptor private var appDelegate: RedditweaksAppDelegate

    private let defaults = UserDefaults(suiteName: "group.com.bermudalocket.redditweaks")!

    @StateObject private var mainViewState = MainViewState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mainViewState)
                .onOpenURL { url in
                    print(url.absoluteString)
                    guard url.absoluteString.starts(with: "rdtwks://") else {
                        return
                    }
                    mainViewState.selectedTab = .liveCommentPreview
                }
        }
        .defaultAppStorage(defaults)
        .windowStyle(HiddenTitleBarWindowStyle())
    }

}

class RedditweaksAppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        SKPaymentQueue.default().add(IAPHelper.shared)
    }

    func applicationWillTerminate(_ notification: Notification) {
        SKPaymentQueue.default().remove(IAPHelper.shared)
    }

}
