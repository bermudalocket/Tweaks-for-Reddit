//
//  AppState.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {

    @Published var selectedTab: SelectedTab? = .welcome

}
