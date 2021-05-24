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

/**
 A bridge to SwiftUI via NSHostingView.
 */
class PopoverViewWrapper: SFSafariExtensionViewController {

    init() {
        super.init(nibName: nil, bundle: nil)

        let view = PopoverView()
            .environmentObject(AppState())
            .environmentObject(IAPHelper.shared)
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            .defaultAppStorage(Redditweaks.defaults)
            .accentColor(.redditOrange)

        self.view = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
