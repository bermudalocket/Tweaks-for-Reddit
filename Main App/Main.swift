//
//  Main.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 10/21/19.
//  Copyright © 2019 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI
import TFRCore
import Tweaks_for_Reddit_Popover

@main
struct RedditweaksApp: App {

    fileprivate static let backgroundTaskActionPipe = PassthroughSubject<MainAppAction, Never>()

    @NSApplicationDelegateAdaptor private var appDelegate: RedditweaksAppDelegate

    private let store = MainAppStore(
        initialState: .init(),
        reducer: mainAppReducer,
        environment: .shared
    )

    private var cancellables = Set<AnyCancellable>()

    init() {
        RedditweaksApp.backgroundTaskActionPipe
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: self.store.send(_:))
            .store(in: &cancellables)

        if #available(macOS 12, *) {
            Task(priority: .background) {
                while true {
                    log("async task created, awaiting awaken")
                    try? await Task.sleep(nanoseconds: UInt64(90 * 1_000_000_000))
                    log("async task awoken - am i cancelled? \(Task.isCancelled ? "Y" : "N")")
                    if !Task.isCancelled {
                        RedditweaksApp.backgroundTaskActionPipe.send(.checkForMessages)
                    }
                }
            }
        } else {
            let backgroundTask = NSBackgroundActivityScheduler(identifier: "com.bermudalocket.redditweaks.background")
            backgroundTask.interval = 90
            backgroundTask.tolerance = 30
            backgroundTask.qualityOfService = .background
            backgroundTask.repeats = true
            backgroundTask.schedule { completion in
                if backgroundTask.shouldDefer {
                    completion(.deferred)
                } else {
                    RedditweaksApp.backgroundTaskActionPipe.send(.checkForMessages)
                    completion(.finished)
                }
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if CommandLine.arguments.contains("--testing") {
                PopoverView(store: .preview)
            } else {
                MainView()
                    .accentColor(.redditOrange)
                    .environmentObject(store)
                    .onOpenURL { url in
                        store.send(.handleDeeplink(url))
                    }
                    .handlesExternalEvents(
                        preferring: Set(["oauth", "iap", "open"]),
                        allowing: Set(["oauth", "iap", "open"])
                    )
                    .onAppear {
                        store.send(.initialize)
                    }
                    .onDisappear {
                        store.send(.save)
                    }
            }
        }
        .defaultAppStorage(TweaksForReddit.defaults)
        .windowStyle(HiddenTitleBarWindowStyle())
    }

}

class RedditweaksAppDelegate: NSObject, NSApplicationDelegate {

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        .terminateNow
    }

    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let size = NSSize(width: 60, height: 60)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let icon = NSImage(systemSymbolName: "wrench.fill", accessibilityDescription: "Tweaks for Reddit Menu Bar App")
        icon?.size = NSSize(width: 20, height: 20)
        statusItem.button?.image = icon
        statusItem.behavior = .removalAllowed

        let menu = NSMenu(title: "Tweaks for Reddit")

        let openItem = NSMenuItem(title: "Open", action: #selector(openMainApp), keyEquivalent: "O")
        let openItemImage = NSImage(systemSymbolName: "note", accessibilityDescription: "Open main app")
        openItemImage?.resizingMode = .stretch
        openItemImage?.size = size
        openItem.image = openItemImage
        menu.addItem(openItem)

        let postItem = NSMenuItem(title: "Submit a post", action: #selector(post), keyEquivalent: "P")
        let postItemImage = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Submit a post")
        postItemImage?.size = size
        postItem.image = postItemImage
        menu.addItem(postItem)

        menu.addItem(.separator())

        var i = 1
        for sub in CoreDataService.shared.favoriteSubreddits.sorted(by: { $0.name! < $1.name! }) {
            if let name = sub.name {
                let key = i < 10 ? "\(i)" : ""
                //                                            | #selector(sub.open) doesn't seem to work here: the NSMenuItem is disabled
                let subItem = NSMenuItem(title: name, action: #selector(self.open(sender:)), keyEquivalent: key)
                let subItemImage = NSImage(systemSymbolName: TweaksForReddit.symbolForSubreddit(name), accessibilityDescription: nil)
                subItemImage?.resizingMode = .stretch
                subItemImage?.size = size
                subItem.image = subItemImage
                menu.addItem(subItem)
                i += 1
            }
        }

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "Q")
        let quitItemImage = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Quit Tweaks for Reddit")
        quitItemImage?.size = size
        quitItem.image = quitItemImage
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func openMainApp() {
        NSWorkspace.shared.open(URL(string: "rdtwks://open")!)
    }

    @objc private func open(sender: Any?) {
        print(type(of: sender))
        if let send = sender as? NSMenuItem {
            print("menu item sender \(send)")
            NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(send.title)")!)
        }
    }

    @objc private func post() {
        NSWorkspace.shared.open(URL(string: "https://www.reddit.com/submit")!)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(self)
    }

}
