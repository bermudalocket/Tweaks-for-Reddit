//
//  OAuthView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 6/13/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import Composable_Architecture
import TFRCore

struct OAuthView: View {

    @EnvironmentObject private var store: Store<MainAppState, MainAppAction, TFREnvironment>

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            VStack(spacing: 10) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .rotationEffect(.degrees(45))
                Text("Authorize API Access")
                    .font(.largeTitle.bold())
            }
            .padding(.horizontal)

            VStack(spacing: 10) {
                Text("Tweaks for Reddit will request permission to access the Reddit API on your behalf.\n")
                    + Text("This permission is necessary for certain features to work.").bold()
                Text("We will ") + Text("never").bold().italic().underline(true, color: .redditOrange) + Text(" create, modify, delete, or vote on content or respond to direct messages,\nchat requests, or ModMail delivered to your account without your permission.")
            }
                .font(.body)
                .multilineTextAlignment(.center)

            Group {
                switch store.state.oauthState {
                    case .started:
                        HStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                                .padding()
                            Text("Waiting to hear back from Reddit...")
                        }

                    case .exchanging:
                        Text("Exchanging code for tokens...")

                    case .failed:
                        Text("Authorization failed :(")

                    case .notStarted:
                        Text("")

                    case .completed:
                        Text("You've successfully authorized API access!")
                }
            }
            .font(.title2.bold())
            .padding()

            HStack {
                Button("Start authorizing \(Image(systemName: "lock"))") {
                    store.send(.beginOAuth)
                }
                    .disabled(store.state.didCompleteOAuth)
                if store.state.didCompleteOAuth {
                    Button("Reauthorize \(Image(systemName: "lock.rotation"))") {
                        store.send(.beginOAuth)
                    }
                }
                NextTabButton()
            }

        }
        .buttonStyle(RedditweaksButtonStyle())
    }

}

struct OAuthView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            OAuthView()
                .environmentObject(
                    MainAppStore.init(
                        initialState: MainAppState(),
                        reducer: .none,
                        environment: .shared
                    )
                )
            OAuthView()
                .environmentObject(MainAppStore(
                    initialState: .init(didCompleteOAuth: true),
                    reducer: .none,
                    environment: .shared
                ))
        }.padding()
    }
}
