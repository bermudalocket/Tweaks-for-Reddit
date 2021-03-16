//
//  DebugView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/16/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct DebugView: View {

    @StateObject private var appState = AppState()

    var body: some View {
        VStack {
            Text("isSettingsExpanded: \(appState.isSettingsExpanded ? "TRUE" : "FALSE")")
            Text("isFeaturesListExpanded: \(appState.isFeaturesListExpanded ? "TRUE" : "FALSE")")

            Button("Force expand Settings") {
                appState.isSettingsExpanded = true
            }
            Button("Force expand Features") {
                appState.isFeaturesListExpanded = true
            }
        }
        .padding()
    }
}

struct DebugView_Previews: PreviewProvider {
    static var previews: some View {
        DebugView()
    }
}
