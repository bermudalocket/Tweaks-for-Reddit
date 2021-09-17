//
//  Store.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

public class Store<State, Action, Environment>: ObservableObject {

    @Published public var state: State
    public let environment: Environment
    private let reducer: Reducer<State, Action, Environment>

    private var cancellables = Set<AnyCancellable>()

    public init(initialState: State, reducer: Reducer<State, Action, Environment>, environment: Environment) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    public func send(_ action: Action) {
        reducer(&state, action, environment)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }

    public func binding<Value>(for keyPath: KeyPath<State, Value>, transform: @escaping (Value) -> Action) -> Binding<Value> {
        Binding<Value>(
            get: { self.state[keyPath: keyPath] },
            set: { self.send(transform($0)) }
        )
    }

    public func derived<DerivedState: Equatable, DerivedAction: Equatable>(
        deriveState: @escaping (State) -> DerivedState,
        deriveAction: @escaping (DerivedAction) -> Action
    ) -> Store<DerivedState, DerivedAction, Environment> {
        let store = Store<DerivedState, DerivedAction, Environment>(
            initialState: deriveState(state),
            reducer: Reducer { _, action, _ in
                self.send(deriveAction(action))
                return Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
            },
            environment: environment
        )
        $state
            .map(deriveState)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &store.$state)
        return store
    }

}
