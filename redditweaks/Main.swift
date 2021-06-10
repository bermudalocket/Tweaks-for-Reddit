//
//  Main.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 10/21/19.
//  Copyright © 2019 Michael Rippe. All rights reserved.
//

import SwiftUI
import StoreKit

@main
struct RedditweaksApp: App {

    // periphery:ignore
    @NSApplicationDelegateAdaptor private var appDelegate: RedditweaksAppDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .accentColor(.redditOrange)
                .environmentObject(IAPHelper.shared)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .onOpenURL { url in
                    guard url.absoluteString.starts(with: "rdtwks://") else {
                        return
                    }
                    Redditweaks.defaults.setValue(SelectedTab.liveCommentPreview, forKey: "selectedTab")
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
                        NSApp.mainWindow?.isMovableByWindowBackground = true
                    }
                }
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

}
