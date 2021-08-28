//
//  OAuthView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 6/13/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

struct OAuthView: View {

    @EnvironmentObject private var store: Store<MainAppState, MainAppAction, TFREnvironment>

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(spacing: 10) {
                Image(systemName: "key")
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
                Text("Authorize API Access")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.horizontal)

            VStack(spacing: 10) {
                Text("Tweaks for Reddit will request permission to access the Reddit API on your behalf.\nThis permission is necessary for certain features to work.")
                Text("We will never create, modify, delete, or vote on content or respond to direct messages,\nchat requests, or ModMail delivered to your account without your permission.")
            }
                .font(.body)
                .multilineTextAlignment(.center)
                .frame(height: 100)

            if store.state.didCompleteOAuth {
                VStack {
                    Text("You've successfully authorized API access!")
                        .font(.title2)
                        .bold()
                    Text("Having problems? Click here to reauthorize.")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .onTapGesture { store.send(.beginOAuth) }
                        .onHover { $0 ? NSCursor.pointingHand.push() : NSCursor.pop() }
                }
            }

            HStack {
                Button("Start authorizing \(Image(systemName: "lock"))") {
                    store.send(.beginOAuth)
                }.buttonStyle(RedditweaksButtonStyle())
                    .disabled(store.state.didCompleteOAuth)
                NextTabButton()
            }

        }
    }

}

struct OAuthView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            OAuthView()
                .environmentObject(MainAppStore.mock)
            OAuthView()
                .environmentObject(MainAppStore(
                    initialState: .init(didCompleteOAuth: true),
                    reducer: .none,
                    environment: .mock
                ))
        }.padding()
    }
}
