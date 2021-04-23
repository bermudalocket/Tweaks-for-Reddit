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

    @State private var isShowingRestoredPurchasesAlert = false

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.calendar = calendar
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
                        .padding(.trailing, 10)
                        .frame(width: 50)
                        .foregroundColor(.blue)
                    Text("Live Previews\n").bold() + Text("See your comments rendered in\nmarkdown in real time")
                }
                HStack {
                    Image(systemName: "laptopcomputer")
                        .font(.system(size: 20))
                        .padding(.trailing, 10)
                        .frame(width: 50)
                        .foregroundColor(.blue)
                    Text("Family Sharing\n").bold() + Text("Use on all of your macOS devices")
                }
                HStack {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 20))
                        .padding(.trailing, 10)
                        .frame(width: 50)
                        .foregroundColor(.blue)
                    Text("Support Development\n").bold() + Text("Tweaks for Reddit is written by a\nsingle developer")
                }
            }
            Spacer()
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
                            Text("Unlock now for $0.99")
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

struct RedditweaksButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline))
            .foregroundColor(.blue)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .foregroundColor(.primary)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1)
                    .animation(.spring())
            )
    }
}

struct InAppPurchases_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchases()
        InAppPurchases()
            .environment(\.colorScheme, .dark)
    }
}
