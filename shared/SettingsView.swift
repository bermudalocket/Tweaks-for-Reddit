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
//                Toggle("Debug", isOn: .constant(true))
//                Toggle("Send Safari and Redditweaks version info to Redditweaks", isOn: .constant(false))
//                    .disabled(true)
//                    .onHover {
//                        $0 ? NSCursor.disappearingItem.push() : NSCursor.pop()
//                    }
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
    }
}
