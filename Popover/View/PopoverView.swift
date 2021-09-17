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
import StoreKit
import SwiftUI
import Composable_Architecture
import TFRCore

public struct PopoverView: View {

    @ObservedObject private var store: PopoverStore

    public init(store: PopoverStore) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 5) {
            VersionView()

            RedditInfoView()
                .frame(width: TweaksForReddit.popoverWidth, height: 150)
                .environmentObject(
                    store.derived(
                        deriveState: \.redditState,
                        deriveAction: PopoverAction.reddit
                    )
                )
                .popover(
                    isPresented: $store.state.isShowingWhatsNew,
                    attachmentAnchor: .rect(.bounds),
                    arrowEdge: Edge.leading
                ) {
                    WhatsNewView(isPresented: $store.state.isShowingWhatsNew)
                }

            if SKPaymentQueue.canMakePayments() {
                GroupBox(label: Text("In-App Purchases")) {
                    HStack {
                        Toggle("Live preview comments in markdown", isOn: store.binding(for: .liveCommentPreview))
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .disabled(!(store.environment.defaults.get(.didPurchaseLiveCommentPreviews) as? Bool ?? false))
                    }
                }
            }
            
            FeaturesListView()
                .environmentObject(store)

            HStack {
                Text("Find a bug? Got a suggestion?")
                Button("Contact us \(Image(systemName: "envelope.fill"))") {
                    store.send(.openFeedbackEmail)
                }
                .buttonStyle(RedditweaksButtonStyle())
                .scaleEffect(0.8)
                .contextMenu {
                    Button("Copy debug info to clipboard") {
                        store.send(.copyDebugInfo)
                    }
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
        PopoverView(store: .shared)
    }
}
