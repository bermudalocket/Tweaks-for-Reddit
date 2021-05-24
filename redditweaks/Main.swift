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

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var appState = MainAppState()

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
                .accentColor(.redditOrange)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                        case .active:
                            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
                                NSApp!.mainWindow!.isMovableByWindowBackground = true
                            }

                        default:
                            return
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
