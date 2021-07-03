//
//  PopoverView.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/6/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI
import TfRCompose
import TfRGlobals

public struct PopoverView: View {

    @EnvironmentObject private var store: ExtensionStore

    public init() {
        
    }

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

            GroupBox(label: Text("Features")) {
                FeaturesListView()
            }

            if store.state.canMakePurchases {
                GroupBox(label: Text("In-App Purchases")) {
                    Toggle("Live preview comments in markdown", isOn: store.binding(for: .liveCommentPreview))
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                }
            }

            GroupBox(label: Text("Settings")) {
                SettingsView()
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
