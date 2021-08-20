//
//  Reducer.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Combine
import Foundation
import StoreKit
import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

typealias ExtensionStore = Store<ExtensionState, ExtensionAction, TFREnvironment>

extension ExtensionStore {
    static let mock = ExtensionStore(
        initialState: .mock,
        reducer: extensionReducer,
        environment: .mock
    )
}

extension Store where State == ExtensionState, Action == ExtensionAction {
    func binding(for feature: Feature) -> Binding<Bool> {
        Binding<Bool> {
            Redditweaks.defaults.bool(forKey: feature.key)
        } set: {
            self.send(.setFeatureState(feature: feature, enabled: $0))
        }
    }
}
