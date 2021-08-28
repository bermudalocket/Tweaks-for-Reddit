//
//  ConnectToSafariView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import SafariServices.SFSafariApplication
import Composable_Architecture
import Tweaks_for_Reddit_Core

struct ConnectToSafariView: View {

    @EnvironmentObject private var store: MainAppStore

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 68))
                    .foregroundColor(.redditOrange)
                Text("Connect to Safari")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding([.horizontal, .bottom])
            VStack(spacing: 10) {
                Text("Connecting to Safari is easy.")
                Text("All you have to do is click a checkbox in Safari's preferences.\nClick the button below to have Safari open to the right spot.")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                if store.state.isSafariExtensionEnabled {
                    Text("The extension is enabled!")
                        .font(.title2)
                        .bold()
                }
                HStack {
                    Spacer()
                    Button("Open in Safari \(Image(systemName: "safari.fill"))") {
                        store.send(.openSafariToExtensionsWindow)
                    }.buttonStyle(RedditweaksButtonStyle())
                    .disabled(store.state.isSafariExtensionEnabled)
                    NextTabButton()
                    Spacer()
                }
            }
        }
        .padding()
        .onAppear {
            store.send(.checkSafariExtensionState)
        }
    }

}

struct ConnectToSafariView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ConnectToSafariView()
                .environmentObject(MainAppStore(
                    initialState: MainAppState(isSafariExtensionEnabled: false),
                    reducer: mainAppReducer,
                    environment: .mock
                ))
            ConnectToSafariView()
                .environmentObject(MainAppStore(
                    initialState: MainAppState(isSafariExtensionEnabled: true),
                    reducer: mainAppReducer,
                    environment: .mock
                ))
        }
    }
}
