//
//  AnyPublisher.swift
//  AnyPublisher
//
//  Created by Michael Rippe on 9/4/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation

extension AnyPublisher {

    public init(value: Output) {
        self.init(Just(value).setFailureType(to: Failure.self))
    }

    public init(error: Failure) {
        self.init(Fail(error: error).eraseToAnyPublisher())
    }

    public static var none: AnyPublisher<Output, Failure> {
        Empty(completeImmediately: true)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

}
