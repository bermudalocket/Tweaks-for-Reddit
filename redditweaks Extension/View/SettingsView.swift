//
//  SettingsView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        GroupBox(label: Text("Settings")) {
            Toggle("Verify favorite subreddits exist when typing",
                   isOn: $appState.doSubredditVerification)
                .disabled(!(appState.features[.customSubredditBar] ?? false))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(10)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.preview)
            .frame(width: 300)
    }
}
