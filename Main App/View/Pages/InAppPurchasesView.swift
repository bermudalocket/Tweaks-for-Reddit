//
//  InAppPurchases.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 4/16/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import StoreKit
import Tweaks_for_Reddit_Core

struct InAppPurchasesView: View {

    @EnvironmentObject private var store: MainAppStore

    @State private var isRestoring = false
    @State private var isShowingScreenshot = false

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 68))
                        .foregroundColor(.accentColor)
                    Text("Live Comment Previews")
                        .font(.system(size: 28, weight: .bold))
                }
                .padding(.horizontal)

                self.benefitsView

                if store.state.canMakePurchases {
                    if store.state.didPurchaseLiveCommentPreviews {
                        Text("Thank you for your support!")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    HStack {
                        if !store.state.didPurchaseLiveCommentPreviews && !isRestoring {
                            Button(action: {
                                store.send(.purchaseLiveCommentPreviews)
                            }) {
                                Text("Unlock now \(Image(systemName: "arrow.right"))")
                            }
                            .buttonStyle(RedditweaksButtonStyle())
                        }
                        Button("See a screenshot") {
                            isShowingScreenshot.toggle()
                        }
                        .buttonStyle(RedditweaksButtonStyle())
                        .popover(isPresented: $isShowingScreenshot,
                                 attachmentAnchor: .rect(.bounds)) {
                            Image("livecommentpreviews")
                                .resizable()
                                .scaledToFit()
                        }
                        if !isRestoring {
                            Button {
                                isRestoring = true
                                store.send(.restorePurchases)
                                DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(3))) {
                                    store.send(.setDidPurchaseLiveCommentPreviews)
                                    self.isRestoring = false
                                }
                            } label: {
                                Text("Restore purchases")
                            }
                            .buttonStyle(RedditweaksButtonStyle())
                        } else {
                            ProgressView()
                                .scaleEffect(0.5)
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 160)
                        }
                        #if DEBUG
                        Button("x") {
                            store.send(.resetIAP)
                            store.send(.setDidPurchaseLiveCommentPreviews)
                        }
                        #endif
                    }
                } else {
                    Text("Payments aren't available on your device.")
                        .font(.title2)
                        .bold()
                }
            }
            .onAppear {
                store.send(.setDidPurchaseLiveCommentPreviews)
            }
        }
    }

    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    .font(.system(size: 20))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Live Previews").bold()
                    Text("See your comments rendered in markdown in real time.")
                }
            }
            HStack {
                Image(systemName: "laptopcomputer")
                    .font(.system(size: 20))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Family Sharing")
                        .bold()
                    Text("Buy it on this macOS device, use it on all the rest.")
                }
            }
            HStack {
                Image(systemName: "hand.thumbsup")
                    .font(.system(size: 20))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Support Development").bold()
                    Text("Tweaks for Reddit is written by one guy!")
                }
            }
        }
    }

}

struct InAppPurchases_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchasesView()
            .padding()
        InAppPurchasesView()
            .environment(\.colorScheme, .dark)
            .padding()
    }
}

extension SKProduct {
	var localizedPrice: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = priceLocale
		return formatter.string(from: price)!
	}
}
