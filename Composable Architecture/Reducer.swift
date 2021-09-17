//
//  Reducer.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation

public struct Reducer<State, Action, Environment> {

    private let reducer: (inout State, Action, Environment) -> AnyPublisher<Action, Never>

    public init(_ reducer: @escaping (inout State, Action, Environment) -> AnyPublisher<Action, Never>) {
        self.reducer = reducer
    }

    public func callAsFunction(_ state: inout State, _ action: Action, _ env: Environment) -> AnyPublisher<Action, Never> {
        reducer(&state, action, env)
    }

}

extension Reducer {
    public static var none: Reducer {
        Self { _, _, _ in Empty().eraseToAnyPublisher() }
    }
}
