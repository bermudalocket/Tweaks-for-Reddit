//
//  PopoverViewWrapper.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
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
            .environmentObject(IAPHelper())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)

        self.view = NSHostingView(rootView: view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
