//
//  AppStoreService.swift
//  Tweaks for Reddit Core
//
//  Created by Michael Rippe on 8/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import StoreKit

public enum InAppPurchase: CaseIterable {
    case liveCommentPreview

    var productId: String {
        switch self {
            case .liveCommentPreview: return "livecommentpreview"
        }
    }
}

public protocol AppStoreService: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    var canMakePayments: Bool { get }
    var productRequest: SKProductsRequest { get }
    var products: [SKProduct] { get set }

    func purchase(_ item: InAppPurchase)
    func restorePurchases()
}

public class AppStoreServiceLive: NSObject, AppStoreService {

    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
        logService("Added service to payment queue", service: .appStore)

        self.productRequest.start()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        logService("Removed service from payment queue", service: .appStore)
    }

    public var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }

    public var productRequest: SKProductsRequest {
        let request = SKProductsRequest(productIdentifiers: Set(InAppPurchase.allCases.map(\.productId)))
        request.delegate = self
        return request
    }

    public var products = [SKProduct]()

    public func purchase(_ item: InAppPurchase) {
        logService("Purchase: \(item)", service: .appStore)
        switch item {
            case .liveCommentPreview:
                guard let item = self.products.first else {
                    logService("Tried to purchase \(item) but self.products.first is null.", service: .appStore)
                    return
                }
                SKPaymentQueue.default().add(SKPayment(product: item))
                logService("Item added to payment queue", service: .appStore)
        }
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
        logService("Restoring completed transactions", service: .appStore)
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        logService("Received products request response", service: .appStore)
        self.products = response.products
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        logService("Received transaction(s)", service: .appStore)
        for transaction in transactions {
            logService("-> \(transaction.payment.productIdentifier) \(transaction.transactionState)", service: .appStore)
            switch transaction.transactionState {
                case .purchased, .restored:
                    let newState = IAPState(context: CoreDataService.live.container.viewContext)
                    newState.liveCommentPreviews = true
                    newState.timestamp = Date()
                    try? CoreDataService.live.container.viewContext.save()
                    SKPaymentQueue.default().finishTransaction(transaction)

                default:
                    continue
            }
        }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {

    }

}
