//
//  Main.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 10/21/19.
//  Copyright © 2019 Michael Rippe. All rights reserved.
//

import Combine
import StoreKit
import SwiftUI
import TfRGlobals
import TFRPopover
import UserNotifications

@main
struct RedditweaksApp: App {

    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor private var appDelegate: RedditweaksAppDelegate

    @StateObject private var store: MainAppStore = CommandLine.arguments.contains("main-ui-testing") ? .mock : .live

    var body: some Scene {
        WindowGroup {
            MainView()
                .accentColor(.redditOrange)
                .environmentObject(store)
                .onOpenURL { url in
                    guard url.absoluteString.starts(with: "rdtwks://") else {
                        return
                    }
                    if url.host == "iap" {
                        store.send(.setTab(.liveCommentPreview))
                    } else if url.host == "oauth" {
                        store.send(.exchangeCodeForTokens(incomingUrl: url))
                    } else if url.host == "auth" {
                        store.send(.setTab(.oauth))
                    }
                }
                .onAppear {
                    store.send(.loadSavedState)
                }
                .onDisappear {
                    store.send(.persistState)
                }
                .handlesExternalEvents(preferring: Set(arrayLiteral: "*"), allowing: Set(arrayLiteral: "*"))
        }
        .defaultAppStorage(Redditweaks.defaults)
        .windowStyle(HiddenTitleBarWindowStyle())
    }

}

class RedditweaksAppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        SKPaymentQueue.default().add(IAPHelper.shared.transactionPublisher)
    }

    func applicationWillTerminate(_ notification: Notification) {
        SKPaymentQueue.default().remove(IAPHelper.shared.transactionPublisher)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

}
