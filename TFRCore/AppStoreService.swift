//
//  AppStoreService.swift
//  TFRCore
//
//  Created by Michael Rippe on 8/24/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import StoreKit

public enum InAppPurchase: CaseIterable {
    case liveCommentPreview

    public var productId: String {
        switch self {
            case .liveCommentPreview: return "livecommentpreview"
        }
    }

    init?(string: String) {
        for iap in InAppPurchase.allCases {
            if iap.productId == string {
                self = iap
            }
        }
        return nil
    }
}

public class AppStoreService: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    private let paymentQueue = SKPaymentQueue.default()

    private let restoreCompletePublisher = PassthroughSubject<Bool, Never>()

    private(set) var products = [SKProduct]()

    override init() {
        super.init()
        paymentQueue.add(self)
        logService("Added service to payment queue", service: .appStore)

        self.productRequest.start()
    }

    deinit {
        paymentQueue.remove(self)
        logService("Removed service from payment queue", service: .appStore)
    }

    public var productRequest: SKProductsRequest {
        let request = SKProductsRequest(productIdentifiers: Set(InAppPurchase.allCases.map(\.productId)))
        request.delegate = self
        return request
    }

    public func purchase(_ item: InAppPurchase) {
        logService("Purchase: \(item)", service: .appStore)
        switch item {
            case .liveCommentPreview:
                guard let item = self.products.first else {
                    logService("Tried to purchase \(item) but self.products.first is null.", service: .appStore)
                    return
                }
                paymentQueue.add(SKPayment(product: item))
                logService("Item added to payment queue", service: .appStore)
        }
    }

    public func restorePurchases() -> AnyPublisher<Bool, Never> {
        paymentQueue.restoreCompletedTransactions()
        logService("Restoring completed transactions", service: .appStore)
        return self.restoreCompletePublisher.eraseToAnyPublisher()
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        logService("Received products request response with \(response.products.count) product(s)", service: .appStore)
        self.products = response.products
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        logService("Received \(transactions.count) transaction(s)", service: .appStore)
        for transaction in transactions {
            switch transaction.transactionState {
                case .purchased, .restored:
                    NSUbiquitousKeyValueStore.default.set(true, forKey: InAppPurchase.liveCommentPreview.productId)

                default:
                    NSUbiquitousKeyValueStore.default.set(false, forKey: InAppPurchase.liveCommentPreview.productId)
            }
        }
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restoreCompletePublisher.send(true)
    }

}
