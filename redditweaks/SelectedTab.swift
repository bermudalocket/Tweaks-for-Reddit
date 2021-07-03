//
//  SelectedTab.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum SelectedTab: String, Codable, CaseIterable, RawRepresentable {

    case welcome = "Welcome"
    case connectToSafari = "Connect to Safari"
    case oauth = "Reddit API Access"
    case toolbar = "The Toolbar Popover"
    case iCloud
    case liveCommentPreview = "Live Comment Previews"
//    case debug = "Debug"

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
            case .liveCommentPreview: return "bold.italic.underline"
//            case .debug: return "ant.fill"
        }
    }

    public init?(rawValue: String) {
        guard let tab = SelectedTab.allCases.filter({ $0.name == rawValue }).first else {
            return nil
        }
        self = tab
    }

}
