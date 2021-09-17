//
//  SelectedTab.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI

enum SelectedTab: String, Codable, CaseIterable, RawRepresentable {

    case welcome = "Welcome"
    case connectToSafari = "Connect to Safari"
    case oauth = "Reddit API Access"
    case notifications = "Notifications"
    case toolbar = "The Toolbar Popover"
    case iCloud
    case liveCommentPreview = "Live Comment Previews"
    case testFlight = "TestFlight"

    var name: String {
        self.rawValue
    }

    var symbol: String {
        switch self {
            case .welcome: return "hand.wave.fill"
            case .connectToSafari: return "safari.fill"
            case .oauth: return "key.fill"
            case .toolbar: return "menubar.arrow.up.rectangle"
            case .iCloud: return "cloud.fill"
            case .liveCommentPreview: return "sparkles.square.fill.on.square"
            case .notifications: return "bell.badge.fill"
            case .testFlight: return "paperplane.fill"
        }
    }

    var next: SelectedTab {
        switch self {
            case .welcome:
                return .connectToSafari
            case .connectToSafari:
                return .oauth
            case .oauth:
                return .notifications
            case .notifications:
                return .toolbar
            case .toolbar:
                return .iCloud
            case .iCloud:
                return .liveCommentPreview
            case .liveCommentPreview:
                return .testFlight
            case .testFlight:
                return .testFlight
        }
    }

    var view: some View {
        Group {
            switch self {
                case .testFlight:
                    TestFlightView()

                case .notifications:
                    NotificationsView()

                case .oauth:
                    OAuthView()

                case .connectToSafari:
                    ConnectToSafariView()

                case .liveCommentPreview:
                    InAppPurchasesView()

                case .welcome:
                    WelcomeView()

                case .iCloud:
                    iCloudView()

                case .toolbar:
                    SafariPopoverView()
            }
        }
    }

    init?(rawValue: String) {
        guard let tab = SelectedTab.allCases.filter({ $0.name == rawValue }).first else {
            return nil
        }
        self = tab
    }

}
