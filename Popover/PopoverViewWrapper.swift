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
import Composable_Architecture
import Tweaks_for_Reddit_Core

/**
 A bridge to SwiftUI via NSHostingView.
 */
public class PopoverViewWrapper: SFSafariExtensionViewController {

    public init() {
        super.init(nibName: nil, bundle: nil)

        let environment = TFREnvironment.live

        let store = Store<ExtensionState, ExtensionAction, TFREnvironment>(
            initialState: ExtensionState(
                redditState: .live,
                favoriteSubreddits: environment.coreData.favoriteSubreddits,
                canMakePurchases: environment.iap.canMakePayments,
                didPurchaseLiveCommentPreviews: environment.defaults.bool(forKey: "didPurchaseLiveCommentPreviews")
            ),
            reducer: extensionReducer,
            environment: environment
        )

        let activity = NSBackgroundActivityScheduler(identifier: "com.bermudalocket.tweaksforreddit")
        activity.interval = 60
        activity.qualityOfService = .background
        activity.repeats = true
        activity.tolerance = 20
        activity.schedule { completion in
            store.send(.reddit(.checkForMessages))
            completion(.finished)
        }

        let view = PopoverView()
            .environmentObject(store)
            .accentColor(.redditOrange)

        self.view = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
