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
        DisclosureGroup(isExpanded: appState.$isSettingsExpanded) {
            VStack(alignment: .leading) {
                if appState.features[.customSubredditBar] ?? false {
                    Toggle("Verify favorite subreddits exist when typing", isOn: $appState.doSubredditVerification)
                }
            }
            .padding(.bottom)
        } label: {
            HStack {
                Text("Settings")
                    .bold()
                Spacer()
            }
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture {
                appState.isSettingsExpanded.toggle()
            }
        }
        .frame(height: appState.isSettingsExpanded ? CGFloat(100) : CGFloat(35)) // TODO: weird compiler error here w/o CGFloat casts
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
