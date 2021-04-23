//
//  StoreKitManager.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import StoreKit

class IAPHelper: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

    // MARK: - singleton
    public static let shared = IAPHelper()
    override private init() {
        super.init()
        fetchProducts()
    }

    // MARK: - properties
    public var canMakePayments = SKPaymentQueue.canMakePayments()
    public var products = [SKProduct]()
    public var purchases = [SKPaymentTransaction]()

    public var purchasedLiveCommentPreviews: Bool {
        purchases.filter { purchase in
            purchase.transactionState == .purchased && purchase.payment.productIdentifier == "livecommentpreview"
        }.count == 1
    }

    // MARK: - StoreKit reference storage
    private var productRequest: SKProductsRequest?

    // MARK: - StoreKit funcs

    private func fetchProducts() {
        let productIdentifiers = Set(["livecommentpreview"])
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest?.delegate = self
        productRequest?.start()
        print("+ started product request")
    }

    // MARK: - Delegate

    /// catches response to fetchProducts()
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            print("product: \($0.localizedTitle)")
            print("description: \($0.localizedDescription)")
            print("price: \($0.price)")
            print("family share: \($0.isFamilyShareable)")
            self.products.append($0)
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("updatedTransactions = \(transactions)")
        transactions.forEach { transaction in
            switch transaction.transactionState {
                case .purchased:
                    print("purchased")
                    purchases.append(transaction)

                default:
                    return
            }
        }
    }

}
