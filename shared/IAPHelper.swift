//
//  StoreKitManager.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import StoreKit

class IAPHelper: NSObject {

    public static let shared = IAPHelper()

    override private init() {
        super.init()
        DispatchQueue.main.async { [self] in
            let productIdentifiers = Set(["livecommentpreview"])
            productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productRequest?.delegate = self
            productRequest?.start()
        }
    }

    public let canMakePayments = SKPaymentQueue.canMakePayments()
    public var products = [SKProduct]()
    public var purchases = [SKPaymentTransaction]()

    public var purchasedLiveCommentPreviews: Bool {
        #if DEBUG
            return true
        #else
            purchases.filter { purchase in
                purchase.transactionState == .purchased && purchase.payment.productIdentifier == "livecommentpreview"
            }.count == 1
        #endif
    }

    public var liveCommentPreviewProduct: SKProduct? {
        products.filter { $0.productIdentifier == "livecommentpreview" }.first
    }

    // strong reference storage
    private var productRequest: SKProductsRequest?

}

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
                case .purchased:
                    purchases.append(transaction)

                default:
                    return
            }
        }
    }
}

extension IAPHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}
