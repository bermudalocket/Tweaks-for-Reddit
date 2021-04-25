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

    // periphery:ignore
    @NSApplicationDelegateAdaptor private var appDelegate: RedditweaksAppDelegate

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .onOpenURL { url in
                    guard url.absoluteString.starts(with: "rdtwks://") else {
                        return
                    }
                    appState.selectedTab = .liveCommentPreview
                }
        }
        .defaultAppStorage(Redditweaks.defaults)
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
