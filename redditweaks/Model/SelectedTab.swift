//
//  SelectedTab.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI

enum SelectedTab: String, CaseIterable {

    case welcome = "Welcome"
    case connectToSafari = "Connect to Safari"
    case toolbar = "The Toolbar Popover"
    case iCloud = "iCloud"
    case liveCommentPreview = "Live Comment Previews"
    case debug = "Debug"

    var name: String {
        self.rawValue
    }

    var view: some View {
        Group {
            switch self {
                case .connectToSafari:
                    ConnectToSafariView()
                        .environmentObject(OnboardingEnvironment())

                case .liveCommentPreview:
                    InAppPurchasesView()

                case .welcome:
                    WelcomeView()
                    
                case .iCloud:
                    iCloudView()

                case .toolbar:
                    PopoverView()

                case .debug:
                    DebugView()
                        .environmentObject(IAPHelper.shared)

            }
        }
        .transition(.opacity.animation(.linear))
    }
}
