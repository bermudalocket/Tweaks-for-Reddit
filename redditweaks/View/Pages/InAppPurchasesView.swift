//
//  InAppPurchases.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 4/16/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import StoreKit

struct InAppPurchasesView: View {

    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale

    @State private var isShowingRestoredPurchasesAlert = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.calendar = calendar
        return formatter
    }

    private var priceFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }

    @State private var isShowingScreenshot = false

    var body: some View {
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

            if IAPHelper.shared.canMakePayments {
                if PersistenceController.shared.iapState.livecommentpreviews {
                    Text("Thank you for your support!\n")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                }

                HStack {
                    if !PersistenceController.shared.iapState.livecommentpreviews {
                        Button("Unlock now for \(IAPHelper.shared.liveCommentPreviewProduct?.price ?? 0.99, formatter: priceFormatter)") {
                            let payment = SKPayment(product: IAPHelper.shared.products.first!)
                            SKPaymentQueue.default().add(payment)
                        }
                        .buttonStyle(RedditweaksButtonStyle())
                    }
                    Button {
                        isShowingScreenshot.toggle()
                    } label: {
                        Text("See a screenshot")
                    }
                    .buttonStyle(RedditweaksButtonStyle())
                    .popover(isPresented: $isShowingScreenshot) {
                        Image("livecommentpreviews")
                            .resizable()
                            .scaledToFit()
                    }
                    Button("Restore Purchases") {
                        SKPaymentQueue.default().restoreCompletedTransactions()
                        isShowingRestoredPurchasesAlert = true
                    }
                    .buttonStyle(RedditweaksButtonStyle())
                    .alert(isPresented: $isShowingRestoredPurchasesAlert) {
                        Alert(title: Text("Success!"), message: Text("If you had any previous purchases, they have been restored."), dismissButton: .default(Text("OK")))
                    }
                }
            } else {
                Text("Payments aren't available on your device.")
                    .font(.title2)
                    .bold()
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
