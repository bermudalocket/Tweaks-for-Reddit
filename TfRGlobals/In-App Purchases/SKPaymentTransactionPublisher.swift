//
//  SKPaymentTransactionPublisher.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/21/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Combine
import StoreKit

public class SKPaymentTransactionPublisher: NSObject, SKPaymentTransactionObserver {

    private let transactionPublisher: PassthroughSubject<[SKPaymentTransaction], Never>
    var publisher: AnyPublisher<[SKPaymentTransaction], Never>

    override init() {
        transactionPublisher = PassthroughSubject<[SKPaymentTransaction], Never>()
        publisher = transactionPublisher.eraseToAnyPublisher()

        super.init()
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactionPublisher.send(transactions)
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        transactionPublisher.send(queue.transactions)
    }

}
