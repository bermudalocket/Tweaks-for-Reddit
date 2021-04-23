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

    @EnvironmentObject private var onboardingEnvironment: OnboardingEnvironment

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                Text("Connect to Safari")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding()

            if onboardingEnvironment.isSafariExtensionEnabled {
                Text("Success!")
                    .bold()
            } else {
                VStack(spacing: 12) {
                    Text("Connecting to Safari is simple.\n\nYou have to manually activate the extension in Safari,\notherwise we can't work our magic on Reddit.")
                        .multilineTextAlignment(.center)
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
        .padding()
    }

}

struct ConnectToSafariView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectToSafariView()
            .environmentObject(OnboardingEnvironment())
    }
}
