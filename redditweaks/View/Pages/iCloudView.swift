//
//  iCloudView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import CloudKit
import SwiftUI

class iCloudEnvironment: ObservableObject {
    var isConnected: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }
}

struct iCloudView: View {

    @EnvironmentObject private var appState: AppState
    @StateObject private var iCloudState = iCloudEnvironment()

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: iCloudState.isConnected ? "checkmark.icloud" : "icloud")
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
                Text("Connect to iCloud")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.horizontal)

            Text("Tweaks for Reddit can store your favorite subreddits in iCloud\nso you can use them on other devices you're signed into.")
                .multilineTextAlignment(.center)

            if iCloudState.isConnected {
                Text("You're signed in and connected to iCloud!")
                    .font(.title2)
                    .bold()
            } else {
                Text("Looks like you're not signed in to iCloud on this device.")
                    .font(.title2)
                    .bold()
            }
        }
    }

}

struct iCloudView_Previews: PreviewProvider {
    static var previews: some View {
        iCloudView()
            .environmentObject(AppState())
            .frame(width: 510)
            .padding()
    }
}
