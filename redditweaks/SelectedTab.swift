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
    case liveCommentPreview = "Live Comment Previews"

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
                    InAppPurchases()

                case .welcome:
                    WelcomeView()

                case .toolbar:
                    VStack {
                        PageView(icon: "bubble.middle.top",
                                 title: "The Popover",
                                 text: "The extension can be accessed in Safari via the toolbar.")
                        Text("From there, you can enable individual features via their checkboxes.")
                        SafariToolbarView()
                            .padding(.vertical)
                    }
            }
        }
    }
}
