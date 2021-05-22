//
//  SKProductsRequestPublisher.swift
//  redditweaks
//
//  Created by Michael Rippe on 5/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import StoreKit

class SKProductsRequestPublisher: NSObject, SKProductsRequestDelegate {

    private let productRequest: SKProductsRequest
    private let productsPublisher: PassthroughSubject<[SKProduct], Never>
    var publisher: AnyPublisher<[SKProduct], Never>

    override init() {
        productRequest = SKProductsRequest(productIdentifiers: Set(TFRProduct.allCases.map(\.rawValue)))
        productsPublisher = PassthroughSubject<[SKProduct], Never>()
        publisher = productsPublisher.eraseToAnyPublisher()

        super.init()
        productRequest.delegate = self
        productRequest.start()
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsPublisher.send(response.products)
    }

}
