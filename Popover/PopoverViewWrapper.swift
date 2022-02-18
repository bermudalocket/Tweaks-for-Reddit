//
//  PopoverViewWrapper.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/6/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import SafariServices
import SwiftUI
import TFRCompose
import TFRCore

/**
 A bridge to SwiftUI via NSHostingView.
 */
public class PopoverViewWrapper: SFSafariExtensionViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)
        logInit("PopoverViewWrapper")

        let environment = TFREnvironment.shared

        let store = PopoverStore(
            initialState: PopoverState(
                redditState: .init(),
                favoriteSubreddits: environment.coreData.favoriteSubreddits
            ),
            reducer: popoverReducer,
            environment: environment
        )

        var activity: NSBackgroundActivityScheduler {
            let activity = NSBackgroundActivityScheduler(identifier: "com.bermudalocket.redditweaks.checkForMessagesTask")
            activity.interval = 60
            activity.qualityOfService = .background
            activity.repeats = true
            activity.tolerance = 20
            activity.schedule { completion in
                if activity.shouldDefer {
                    logService("Deferring task", service: .background)
                    completion(.deferred)
                } else {
                    logService("Checking for messages...", service: .background)
                    store.send(.reddit(.checkForMessages))
                    completion(.finished)
                }
            }
            return activity
        }

        let view = PopoverView(store: store)
//            .environmentObject(store)
            .environment(\.managedObjectContext, environment.coreData.container.viewContext)
            .accentColor(.redditOrange)

        self.view = NSHostingView(rootView: view)
    }

    deinit {
        logDeinit("PopoverViewWrapper")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
