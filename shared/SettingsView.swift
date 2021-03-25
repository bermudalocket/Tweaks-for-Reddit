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

    private var chevron: Image {
        Image(systemName: "chevron.\(appState.isSettingsExpanded ? "down" : "right")")
    }

    var body: some View {
        GroupBox(label: Text("Settings")) {
            VStack(alignment: .leading) {
                Toggle("Verify favorite subreddits exist when typing", isOn: $appState.doSubredditVerification)
                    .disabled(!(appState.features[.customSubredditBar] ?? false))
            }
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState.preview)
            .onAppear {
                AppState.preview.isSettingsExpanded = true
            }
            .frame(width: 300)
    }
}
