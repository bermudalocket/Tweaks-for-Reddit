//
//  InAppPurchases.swift
//  Tweaks for Reddit Extension
//
//  Created by Michael Rippe on 4/16/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI
import StoreKit
import TFRCore
import Tweaks_for_Reddit_Popover

struct InAppPurchasesView: View {

    @EnvironmentObject private var store: MainAppStore

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
                    .padding()
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(Color(.textBackgroundColor))
                    )

                if store.state.canMakePurchases {
                    switch store.state.receiptValidationStatus {
                        case .valid:
                            Text("Thank you for your support!")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)

                        case .invalid:
                            Text("Your receipt was returned from Apple as invalid.")

                        case .networkError:
                            Text("A network error occurred.")

                        case .checking:
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .progressViewStyle(CircularProgressViewStyle())
                                Text("Verifying receipt with Apple...")
                            }

                        case .noReceiptFile:
                            Text("Your receipt file does not exist. Try restoring purchases.\nIf this keeps happening, you probably didn't purchase anything.")
                                .foregroundColor(.red)
                                .bold()
                                .multilineTextAlignment(.center)

                        case .receiptMalformed:
                            Text("Your receipt file is malformed. Try restoring purchases.")

                        case .none:
                            EmptyView()
                    }
                    HStack {
                        Button("Unlock now \(Image(systemName: "arrow.right"))") {
                            store.send(.purchaseLiveCommentPreviews)
                        }
                            .buttonStyle(RedditweaksButtonStyle())
                            .disabled(store.state.receiptValidationStatus == .valid || store.state.isRestoringPurchases)
                        Button("See a screenshot \(Image(systemName: "camera.viewfinder"))") {
                            isShowingScreenshot.toggle()
                        }
                            .buttonStyle(RedditweaksButtonStyle())
                            .popover(
                                isPresented: store.binding(for: \.isShowingScreenshot, transform: MainAppAction.showScreenshot),
                                attachmentAnchor: .rect(.bounds)
                            ) {
                                Image("livecommentpreviews")
                                    .resizable()
                                    .scaledToFit()
                            }
                        Button(action: { store.send(.restorePurchases) }) {
                            if store.state.isRestoringPurchases {
                                ProgressView()
                                    .scaleEffect(0.5)
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(width: 150, height: 20)
                            } else {
                                Text("Restore purchases \(Image(systemName: "arrow.counterclockwise"))")
                            }
                        }
                            .buttonStyle(RedditweaksButtonStyle())
                            .disabled(store.state.isRestoringPurchases)
                    }
                } else {
                    Text("Payments aren't available on your device.")
                        .font(.title2)
                        .bold()
                }
            }
            .onAppear {
                store.send(.validateReceipt)
            }
        }
    }

    private let textColor = Color(.controlTextColor)
    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: SelectedTab.liveCommentPreview.symbol)
                    .font(.system(size: 25))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Live Previews")
                        .font(.headline)
                    Text("See your comments rendered in markdown in real time.")
                        .foregroundColor(textColor)
                }
            }
            HStack {
                MacDevicesSymbol()
                    .font(.system(size: 13))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Family Sharing")
                        .font(.headline)
                    Text("Buy it on this macOS device and use it on all your others.")
                        .font(.body)
                        .foregroundColor(textColor)
                }
            }
            HStack {
                Image(systemName: "face.smiling")
                    .font(.system(size: 25))
                    .frame(width: 50)
                    .foregroundColor(.accentColor)
                VStack(alignment: .leading) {
                    Text("Support Development")
                        .font(.headline)
                    Text("Tweaks for Reddit is written by a solo developer.")
                        .foregroundColor(textColor)
                }
            }
        }
    }

}

struct InAppPurchases_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchasesView()
            .padding()
            .environmentObject(MainAppStore(initialState: MainAppState.init(), reducer: mainAppReducer, environment: .mocked()))
    }
}
