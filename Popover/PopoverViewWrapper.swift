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

    public init(onAppear: @escaping () -> Void) {
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

        let view = PopoverView(store: store)
            .environment(\.managedObjectContext, environment.coreData.container.viewContext)
            .accentColor(.redditOrange)
            .onAppear(perform: onAppear)

        self.view = NSHostingView(rootView: view)
    }

    deinit {
        logDeinit("PopoverViewWrapper")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
