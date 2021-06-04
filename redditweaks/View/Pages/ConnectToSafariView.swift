//
//  ConnectToSafariView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import SafariServices.SFSafariApplication

struct ConnectToSafariView: View {

    @State private var isSafariExtensionEnabled = false

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
                if isSafariExtensionEnabled {
                    Text("The extension is enabled!")
                        .font(.title2)
                        .bold()
                } else {
                    Button("Open in Safari") {
                        SFSafariApplication.showPreferencesForExtension(withIdentifier: "com.bermudalocket.redditweaks.extension") {
                            if let error = $0 {
                                NSLog("Error opening Safari: \(error).")
                            }
                        }
                    }
                    .buttonStyle(RedditweaksButtonStyle())
                }
            }
        }
        .onAppear {
            SFSafariExtensionManager.getStateOfSafariExtension(withIdentifier: "com.bermudalocket.redditweaks.extension") { state, error in
                self.isSafariExtensionEnabled = state?.isEnabled ?? false
            }
        }
    }

}

struct ConnectToSafariView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectToSafariView()
            .environmentObject(OnboardingEnvironment())
            .frame(width: 510)
    }
}
