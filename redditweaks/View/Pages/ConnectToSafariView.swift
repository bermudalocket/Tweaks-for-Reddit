//
//  ConnectToSafariView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import SafariServices.SFSafariApplication
import TfRCompose
import TfRGlobals

struct ConnectToSafariView: View {

    @EnvironmentObject private var store: Store<MainAppState, MainAppAction, TFREnvironment>

    private lazy var timer = Timer(timeInterval: 2, repeats: true) { [self] _ in
        self.store.send(.updateSafariExtensionState)
    }

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
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
                } else {
                    Button("Open in Safari") {
                        store.send(.openSafariToExtensionsWindow)
                    }
                }
            }
        }
        .padding()
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
