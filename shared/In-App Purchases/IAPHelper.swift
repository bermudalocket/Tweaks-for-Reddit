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

    private let paymentQueue = SKPaymentQueue.default()
    let canMakePayments = SKPaymentQueue.canMakePayments()

    let transactionPublisher = SKPaymentTransactionPublisher()
    let productsPublisher = SKProductsRequestPublisher()
    private var cancellables = Set<AnyCancellable>()

    @Published var currentTransactionStatus: SKPaymentTransactionState?
    @Published var products = [SKProduct]()

    @Published var isValidating = false
    @Published var receiptValidationError: AppStoreValidationError?

    private(set) var didPurchaseLiveCommentPreviews: Bool {
        get {
            Redditweaks.defaults.bool(forKey: "didPurchaseLiveCommentPreviews")
        }
        set {
            Redditweaks.defaults.setValue(newValue, forKey: "didPurchaseLiveCommentPreviews")
        }
    }


    private init() {
        productsPublisher.publisher
            .receive(on: DispatchQueue.main)
            .sink { self.products = $0 }
            .store(in: &cancellables)
        transactionPublisher.publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handleTransactions(_:))
            .store(in: &cancellables)

        if !didPurchaseLiveCommentPreviews {
            // ^ don't risk disabling this on someone if, e.g., my website goes down
            validateReceipt()
        }
    }

    func validateReceipt()  {
        self.isValidating = true
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
              FileManager.default.fileExists(atPath: appStoreReceiptURL.path)
        else {
            self.receiptValidationError = .noLocalReceipt
            self.isValidating = false
            return
        }
        guard let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
            self.receiptValidationError = .localReceiptMalformed
            self.isValidating = false
            return
        }

        let receipt = AppStoreValidationRequest(receipt: receiptData.base64EncodedString(options: []), identifier: Redditweaks.identifier)
        var request = URLRequest(url: URL(string: "https://www.bermudalocket.com/verify-receipt")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let body = try? JSONEncoder().encode(receipt) else {
            self.receiptValidationError = .couldNotEncode
            self.isValidating = false
            return
        }
        request.httpBody = body

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [AppStoreValidationResponse].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                    case .failure(let error):
                        self.receiptValidationError = .urlSessionError(error: error)

                    case .finished: break
                }
                self.isValidating = false
            } receiveValue: { result in
                for receipt in result {
                    if receipt.id == "livecommentpreview" {
                        self.didPurchaseLiveCommentPreviews = true
                    }
                }
            }.store(in: &cancellables)
    }

    private func handleTransactions(_ transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            self.currentTransactionStatus = transaction.transactionState
            switch transaction.transactionState {
                case .purchased:
                    didPurchaseLiveCommentPreviews = true
                    paymentQueue.finishTransaction(transaction)

                case .restored:
                    didPurchaseLiveCommentPreviews = true

                default:
                    continue
            }
        }
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
