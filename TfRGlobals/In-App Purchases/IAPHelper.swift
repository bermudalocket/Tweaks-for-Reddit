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

public class IAPHelper: ObservableObject {

    public static let shared = IAPHelper()

    private let paymentQueue = SKPaymentQueue.default()

    public let canMakePayments = SKPaymentQueue.canMakePayments()

    public let transactionPublisher = SKPaymentTransactionPublisher()
    public let productsPublisher = SKProductsRequestPublisher()
    private var cancellables = Set<AnyCancellable>()

    public let transactionStatusPublisher = PassthroughSubject<SKPaymentTransactionState, Never>()
    @Published public var currentTransactionStatus: SKPaymentTransactionState?

    @Published public var products = [SKProduct]()

    @Published public var isValidating = false
    @Published public var receiptValidationError: AppStoreValidationError?

    private(set) public var didPurchaseLiveCommentPreviews: Bool {
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

    func askForReview() {
        SKStoreReviewController.requestReview()
    }

    public func validateReceipt() {
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
                for receipt in result where receipt.id == "livecommentpreview" {
                    self.didPurchaseLiveCommentPreviews = true
                }
            }.store(in: &cancellables)
    }

    private func handleTransactions(_ transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            self.transactionStatusPublisher.send(transaction.transactionState)
            switch transaction.transactionState {
                case .purchased, .restored:
                    didPurchaseLiveCommentPreviews = true
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: .init(entityName: "IAPState"))
                    let deleteResult = try? CoreDataService.live.container.viewContext.execute(deleteRequest)
                    let newState = IAPState(context: CoreDataService.live.container.viewContext)
                    newState.liveCommentPreviews = true
                    newState.timestamp = Date()
                    try? CoreDataService.live.container.viewContext.save()
                    paymentQueue.finishTransaction(transaction)

                default:
                    continue
            }
        }
    }

    public func purchaseLiveCommentPreviews() {
        guard let product = products.first else {
            return
        }
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }

    public func restorePurchases() {
        didPurchaseLiveCommentPreviews = false
        paymentQueue.restoreCompletedTransactions()
    }

}
