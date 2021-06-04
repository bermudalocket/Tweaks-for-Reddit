//
//  AppStoreValidationRequest.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation

enum AppStoreValidationError: Error, LocalizedError {
    case noLocalReceipt
    case localReceiptMalformed
    case couldNotEncode
    case badResponse
    case urlSessionError(error: Error)

    public var errorDescription: String? {
        switch self {
            case .badResponse: return "Received a bad response from the validation server"
            case .couldNotEncode: return "Failed to encode request"
            case .localReceiptMalformed: return "The local App Store receipt is malformed"
            case .noLocalReceipt: return "No local App Store receipt could be found"
            case .urlSessionError(error: let error):
                return "A URLSession error occurred: \(error.localizedDescription)"
        }
    }
}

struct AppStoreValidationRequest: Encodable {
    let receipt: String
    let identifier: UUID
}

struct AppStoreValidationResponse: Decodable {
    let id: String
    var quantity: Int {
        get { Int(internalQuantity) ?? -1 }
    }
    var transactionId: Int {
        get { Int(internalTransactionId) ?? -1 }
    }
    var purchaseDate: Date {
        get { Date(timeIntervalSince1970: Double(internalPurchaseDate) ?? -1) }
    }
    var isTrial: Bool {
        get { internalIsTrial == "true" }
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
