//
//  StoreKitManager.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import StoreKit
import SwiftUI

class IAPHelper: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, ObservableObject {

    enum Product: String, CaseIterable {
        case liveCommentPreviews = "livecommentpreview"
    }

    @Published var canMakePayments = SKPaymentQueue.canMakePayments()
    @Published var products = [SKProduct]()
    @Published var purchases = [SKPaymentTransaction]()

    private var productRequestStorage = [SKProductsRequest]()

    public static let shared = IAPHelper()

    override init() {
        super.init()

        let productRequest = SKProductsRequest(productIdentifiers: Set(Product.allCases.map(\.rawValue)))
        productRequest.delegate = self
        productRequest.start()
        productRequestStorage.append(productRequest)

        self.purchasedLiveCommentPreviews = PersistenceController.shared.iapState.livecommentpreviews
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    func product(_ product: Product) -> SKProduct? {
        products.filter { $0.productIdentifier == product.rawValue }.first
    }

    @Published var purchasedLiveCommentPreviews = false

    public var liveCommentPreviewProduct: SKProduct? {
        products.filter { $0.productIdentifier == "livecommentpreview" }.first
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            if transaction.payment.productIdentifier == "livecommentpreview" {
                switch transaction.transactionState {
                    case .purchased, .restored:
                        let newIAPState = IAPState(context: PersistenceController.shared.container.viewContext)
                        newIAPState.timestamp = Date()
                        newIAPState.livecommentpreviews = true
                        try? PersistenceController.shared.container.viewContext.save()
                        
                        self.purchasedLiveCommentPreviews = true
                        purchases.append(transaction)
                        SKPaymentQueue.default().finishTransaction(transaction)

                    default:
                        return
                }
            }
        }
    }

}

