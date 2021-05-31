//
//  InAppPurchases.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 4/16/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import StoreKit

struct InAppPurchasesView: View {

    @Environment(\.locale) private var locale

    @EnvironmentObject private var iapHelper: IAPHelper

    @State private var isRestoring = false
    @State private var didMakePurchase = false
    @State private var didRestorePurchase = false
    @State private var didDeferPurchase = false
    @State private var didFailPurchase = false

    @State private var isShowingScreenshot = false

    @AppStorage("dontPlayAnimation", store: Redditweaks.defaults)
    private var dontPlayAnimation = false

    private var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }

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

                if iapHelper.canMakePayments {
                    if iapHelper.didPurchaseLiveCommentPreviews {
                        Text("Thank you for your support!")
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    HStack {
                        if !iapHelper.didPurchaseLiveCommentPreviews && !isRestoring {
                            Button(action: iapHelper.purchaseLiveCommentPreviews) {
								Text("Unlock now for \(IAPHelper.shared.products.first?.localizedPrice ?? "$0.99")")
                            }
                        }
                        Button("See a screenshot") {
                            isShowingScreenshot.toggle()
                        }
                        .popover(isPresented: $isShowingScreenshot,
                                 attachmentAnchor: .rect(.bounds)) {
                            Image("livecommentpreviews")
                                .resizable()
                                .scaledToFit()
                        }
                        if !isRestoring {
                            Button {
                                isRestoring = true
                                iapHelper.restorePurchases()
                            } label: {
                                Text("Restore purchases")
                            }
                        } else {
                            ProgressView()
                                .scaleEffect(0.5)
                                .progressViewStyle(CircularProgressViewStyle())
                                .frame(width: 160)
                        }
                    }
                    .buttonStyle(RedditweaksButtonStyle())
                } else {
                    Text("Payments aren't available on your device.")
                        .font(.title2)
                        .bold()
                }
                if didMakePurchase || didRestorePurchase {
                    Toggle(isOn: $dontPlayAnimation, label: {
                        Text("Don't play the awesome confetti animation again")
                            .font(.caption)
                    })
                }
            }
            if (didMakePurchase || didRestorePurchase) && !dontPlayAnimation {
                ConfettiView()
            }
        }
        .onReceive(iapHelper.$currentTransactionStatus) { transactionState in
            switch transactionState {
                case .purchased:
                    self.didMakePurchase = true

                case .deferred:
                    self.didDeferPurchase = true

                case .failed:
                    self.didFailPurchase = true

                case .restored:
                    self.didRestorePurchase = true
                    self.isRestoring = false

                default: return
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
