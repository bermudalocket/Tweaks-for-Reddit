//
//  SettingsView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        GroupBox(label: Text("Settings")) {
            VStack(alignment: .leading) {
                Toggle("Verify favorite subreddits exist",
                       isOn: $appState.doSubredditVerification)
                    .disabled(!(appState.features[.customSubredditBar] ?? false))
                    .padding(5)
                    .help("Tweaks for Reddit will make a request to https://www.reddit.com/r/(sub) to check if it exists")
                HStack {
                    Text("Favorites display size")
                        .frame(minWidth: 0, maxWidth: .infinity)
                    Menu(appState.favoriteSubredditListHeight.displayName) {
                        Button("Small") {
                            appState.favoriteSubredditListHeight = .small
                        }
                        Button("Medium") {
                            appState.favoriteSubredditListHeight = .medium
                        }
                        Button("Large") {
                            appState.favoriteSubredditListHeight = .large
                        }
                    }
                }
                .contentShape(Rectangle())
                .help("Determines how many subreddits are visible in the Favorite Subreddits list")
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(5)
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
