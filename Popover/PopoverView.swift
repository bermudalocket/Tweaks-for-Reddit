//
//  PopoverView.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/6/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import AppKit
import Combine
import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

struct PopoverView: View {

    @EnvironmentObject private var store: ExtensionStore

    var body: some View {
        VStack(spacing: 10) {
            Text("Tweaks for Reddit v\(TweaksForReddit.version)")
                .font(.callout)
                .foregroundColor(.gray)

            RedditInfoView()
                .frame(width: TweaksForReddit.popoverWidth, height: 175)
                .environmentObject(
                    store.derived(
                        deriveState: \.redditState,
                        deriveAction: ExtensionAction.reddit
                    )
                )

            if store.state.canMakePurchases {
                GroupBox(label: Text("In-App Purchases")) {
                    Toggle("Live preview comments in markdown", isOn: store.binding(for: .liveCommentPreview))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
            }
            
            GroupBox(label: Text("Features")) {
                FeaturesListView()
            }

            HStack {
                Text("Find a bug? Got a suggestion?")
                Button("Contact us") {
                    NSWorkspace.shared.open(URL(string: "mailto:support@bermudalocket.com?subject=Tweaks%20for%20Reddit%20Feedback&body=\(TweaksForReddit.debugInfo.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!)
                }
            }
        }
        .padding(10)
        .frame(width: TweaksForReddit.popoverWidth, alignment: .top)
        .onAppear {
            store.send(.load)
        }
        .onDisappear {
            store.send(.save)
            #if !DEBUG
            store.send(.askForReview)
            #endif
        }
    }

}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
            .environmentObject(ExtensionStore.mock)
    }
}
