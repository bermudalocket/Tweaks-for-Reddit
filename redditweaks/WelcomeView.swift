//
//  WelcomeView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to ")
            Text("Tweaks for Reddit")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .padding(.bottom)
            Button {
                appState.selectedTab = .connectToSafari
            } label: {
                Text("Next")
                    .font(.headline)
                    .padding(.horizontal)
            }
            .buttonStyle(RedditweaksButtonStyle())
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppState())
    }
}
