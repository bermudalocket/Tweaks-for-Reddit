//
//  InAppPurchases.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 4/16/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import StoreKit

struct InAppPurchases: View {

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

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "keyboard")
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                Text("Live Comment Previews")
                    .font(.system(size: 32, weight: .bold))
            }

            Spacer().frame(height: 25)

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                        .font(.system(size: 20))
                        .frame(width: 50)
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Live Previews").bold()
                        Text("See your comments rendered in markdown in real time.")
                    }
                }
                HStack {
                    Image(systemName: "laptopcomputer")
                        .font(.system(size: 20))
                        .frame(width: 50)
                        .foregroundColor(.blue)
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
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("Support Development").bold()
                        Text("Tweaks for Reddit is written by one guy!")
                    }
                }
            }
            Spacer()
                .frame(height: 50)
            if IAPHelper.shared.canMakePayments {
                if IAPHelper.shared.purchases.count > 0 {
                        (Text("Thank you for your support!\n")
                            .bold() +
                        Text("Purchased on \(IAPHelper.shared.purchases.first!.transactionDate!, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.gray))
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                } else {
                    HStack {
                        Button {
                            let payment = SKPayment(product: IAPHelper.shared.products.first!)
                            SKPaymentQueue.default().add(payment)
                        } label: {
                            Text("Unlock now for \(IAPHelper.shared.liveCommentPreviewProduct?.price ?? 0.99, formatter: priceFormatter)")
                                .foregroundColor(.blue)
                                .bold()
                                .animation(.spring())
                        }
                            .buttonStyle(RedditweaksButtonStyle())
                        Button {
                            SKPaymentQueue.default().restoreCompletedTransactions()
                            isShowingRestoredPurchasesAlert = true
                        } label: {
                            Text("Restore Purchases")
                                .foregroundColor(.blue)
                                .bold()
                                .animation(.spring())
                        }
                            .buttonStyle(RedditweaksButtonStyle())
                            .alert(isPresented: $isShowingRestoredPurchasesAlert) {
                                Alert(title: Text("Success!"), message: Text("If you had any previous purchases, they have been restored."), dismissButton: .default(Text("OK")))
                            }
                    }
                }
            } else {
                Text("Payments aren't available on your device.")
            }
            Spacer()
        }
    }

}

struct InAppPurchases_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchases()
            .padding()
        InAppPurchases()
            .environment(\.colorScheme, .dark)
            .padding()
    }
}
