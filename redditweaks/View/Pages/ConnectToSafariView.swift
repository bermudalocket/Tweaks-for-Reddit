//
//  ConnectToSafariView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import SafariServices.SFSafariApplication

struct ConnectToSafariView: View {

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingEnvironment: OnboardingEnvironment

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
                Text("Connecting to Safari is easy")
                    .font(.headline) + Text(".")
                Text("All you have to do is click a checkbox in Safari's preferences.\nClick the button below to have Safari open to the right spot.")
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
                Button("Open in Safari") {
                    SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks.extension") {
                        if let error = $0 {
                            NSLog("Error opening Safari: \(error).")
                        }
                    }
                }
                .disabled(onboardingEnvironment.isSafariExtensionEnabled)
                .buttonStyle(RedditweaksButtonStyle())
            }
        }
    }

}

struct ConnectToSafariView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectToSafariView()
            .environmentObject(OnboardingEnvironment())
            .environmentObject(AppState())
            .frame(width: 510)
    }
}
