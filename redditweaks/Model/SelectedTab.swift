//
//  SelectedTab.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Foundation
import SwiftUI

enum SelectedTab: String, Codable, CaseIterable, RawRepresentable {

    case welcome = "Welcome"
    case connectToSafari = "Connect to Safari"
    case toolbar = "The Toolbar Popover"
    case iCloud = "iCloud"
    case liveCommentPreview = "Live Comment Previews"
    case debug = "Debug"

    var name: String {
        self.rawValue
    }

    public init?(rawValue: String) {
        guard let tab = SelectedTab.allCases.filter({ $0.name == rawValue }).first else {
            return nil
        }
        self = tab
    }

}
