//
//  NotificationsView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 8/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import UserNotifications
import TFRCore

struct NotificationsView: View {

    @EnvironmentObject private var store: MainAppStore

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: SelectedTab.notifications.symbol)
                    .renderingMode(.original)
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
                Text(SelectedTab.notifications.name)
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.horizontal)

            Text("Tweaks for Reddit offers an alternative notification system\nto replace the broken Reddit system on Safari.")
                .multilineTextAlignment(.center)

            Text("Please note that notification-related features are currently in beta.")

            if store.state.notificationsEnabled {
                VStack {
                    Text("Notifications are enabled!")
                        .font(.title2)
                        .bold()
                    Text("Changes can be made in System Preferences.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
            }
            if store.state.oauthState != .completed {
                HStack {
                Text("This feature requires OAuth authorization.")
                    .font(.title2)
                    .bold()
                    Button("Go \(Image(systemName: "arrow.right"))") {
                        store.send(.setTab(.oauth))
                    }
                }
            }
            HStack {
                Button("Request notifications \(Image(systemName: "lock"))") {
                    store.send(.requestNotificationAuthorization)
                }.buttonStyle(RedditweaksButtonStyle())
                    .disabled(store.state.notificationsEnabled || store.state.oauthState != .completed)
                NextTabButton()
            }
        }.onAppear {
            store.send(.checkNotificationsEnabled)
        }
    }

}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NotificationsView()
                .environmentObject(MainAppStore(
                    initialState: MainAppState(notificationsEnabled: false),
                    reducer: .none,
                    environment: .shared))
            NotificationsView()
                .environmentObject(MainAppStore(
                    initialState: MainAppState(notificationsEnabled: true),
                    reducer: .none,
                    environment: .shared))
        }
        .padding()
        .frame(width: 510)
        .accentColor(.redditOrange)
    }
}
