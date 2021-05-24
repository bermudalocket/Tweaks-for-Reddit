//
//  StoreKitManager.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/20/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Combine
import StoreKit
import SwiftUI

class IAPHelper: ObservableObject {

    public static let shared = IAPHelper()

    let canMakePayments = SKPaymentQueue.canMakePayments()

    let transactionPublisher = SKPaymentTransactionPublisher()
    let productsPublisher = SKProductsRequestPublisher()
    private var cancellables = Set<AnyCancellable>()

    @Published var currentTransactionStatus: SKPaymentTransactionState?
    @Published var products = [SKProduct]()
    @Published var purchases = [SKPaymentTransaction]()

    private let paymentQueue = SKPaymentQueue.default()

    @AppStorage("didPurchaseLiveCommentPreviews", store: Redditweaks.defaults)
    private(set) var didPurchaseLiveCommentPreviews = false

    init() {
        productsPublisher.publisher
            .receive(on: DispatchQueue.main)
            .sink { self.products = $0 }
            .store(in: &cancellables)
        transactionPublisher.publisher
            .receive(on: DispatchQueue.main)
            .sink {
                self.purchases = $0
                self.purchases
                    .forEach { [self] transaction in
                        self.currentTransactionStatus = transaction.transactionState
                        switch transaction.transactionState {
                            case .purchased:
                                didPurchaseLiveCommentPreviews = true
                                paymentQueue.finishTransaction(transaction)

                            case .restored:
                                didPurchaseLiveCommentPreviews = true

                            default:
                                return
                        }
                    }
            }
            .store(in: &cancellables)
    }

    func purchaseLiveCommentPreviews() {
        guard let product = products.first else {
            return
        }
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }

    func restorePurchases() {
        didPurchaseLiveCommentPreviews = false
        paymentQueue.restoreCompletedTransactions()
    }

}
