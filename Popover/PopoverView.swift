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

public struct PopoverView: View {

    @EnvironmentObject private var store: ExtensionStore

    public var body: some View {
        VStack(spacing: 10) {
            Text("Tweaks for Reddit v\(Redditweaks.version)")
                .font(.callout)
                .foregroundColor(.gray)

            if store.state.enableOAuthFeatures {
                RedditInfoView()
                    .frame(width: Redditweaks.popoverWidth, height: 175)
                    .environmentObject(
                        store.derived(
                            deriveState: \.redditState,
                            deriveAction: ExtensionAction.reddit
                        )
                    )
            }

            if store.state.canMakePurchases {
                GroupBox(label: Text("In-App Purchases")) {
                    Toggle("Live preview comments in markdown", isOn: store.binding(for: .liveCommentPreview))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .alert(isPresented: $store.state.isShowingDidNotPurchaseLiveCommentPreviewsError) {
                            Alert(
                                title: Text("Something went wrong..."),
                                message: Text("Either you have not purchased this in-app purchase, or something went wrong detecting your receipt. Try restoring your purchase through the main Tweaks for Reddit app, and if that fails, contact us for support on GitHub."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }
            }
            
            GroupBox(label: Text("Features")) {
                FeaturesListView()
            }

            HStack {
                Text("Find a bug? Got a suggestion?")
                Button("Contact us") {
                    NSWorkspace.shared.open(URL(string: "mailto:support@eigenstuff.net?subject=Tweaks%20for%20Reddit%20Feedback&body=\(Redditweaks.debugInfo.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!)
                }
            }
        }
        .padding(10)
        .frame(width: Redditweaks.popoverWidth, alignment: .top)
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
