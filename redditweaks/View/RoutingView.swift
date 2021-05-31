//
//  DestinationView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/28/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct RoutingView: View {

    let tab: SelectedTab

    var body: some View {
        switch tab {
            case .connectToSafari:
                ConnectToSafariView()
                    .environmentObject(OnboardingEnvironment())

            case .liveCommentPreview:
                InAppPurchasesView()
                    .environmentObject(IAPHelper.shared)

            case .welcome:
                WelcomeView()

            case .iCloud:
                iCloudView()

            case .toolbar:
                SafariPopoverView()

            case .debug:
                DebugView()
                    .environmentObject(IAPHelper.shared)
        }
    }
}
