//
//  AppState.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Foundation
import SwiftUI

class MainAppState: ObservableObject {

    @AppStorage("selectedTab") var selectedTab: SelectedTab = .welcome

}
