//
//  AppStoreValidationRequest.swift
//  TFRCore
//
//  Created by Michael Rippe on 6/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

public struct AppStoreValidationRequest: Encodable {
    let receipt: String
    let identifier: UUID

    public init(receipt: String, identifier: UUID) {
        self.receipt = receipt
        self.identifier = identifier
    }
}

public struct AppStoreValidationResponse: Decodable {

    public let id: String

    var quantity: Int {
        Int(internalQuantity) ?? -1
    }
    var transactionId: Int {
        Int(internalTransactionId) ?? -1
    }
    var purchaseDate: Date {
        Date(timeIntervalSince1970: Double(internalPurchaseDate) ?? -1)
    }
    var isTrial: Bool {
        internalIsTrial == "true"
    }

    private let internalQuantity: String
    let internalTransactionId: String
    let internalPurchaseDate: String
    let internalIsTrial: String

    enum CodingKeys: String, CodingKey {
        case id = "product_id"
        case internalQuantity = "quantity"
        case internalTransactionId = "transaction_id"
        case internalPurchaseDate = "original_purchase_date_ms"
        case internalIsTrial = "is_trial_period"
    }
}
