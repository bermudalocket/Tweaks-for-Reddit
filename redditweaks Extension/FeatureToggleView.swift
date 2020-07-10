//
//  FeatureToggleView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

class FeatureToggleViewModel: ObservableObject {

    let feature: Feature

    @Published var enabled: Bool

    init(feature: Feature) {
        self.feature = feature
        self.enabled = Redditweaks.defaults.bool(forKey: feature.name)
    }

}

struct FeatureToggleView: View {

    @ObservedObject private var viewModel: FeatureToggleViewModel

    init(feature: Feature) {
        self.viewModel = FeatureToggleViewModel(feature: feature)
    }

    var body: some View {
        Toggle(viewModel.feature.description, isOn: $viewModel.enabled)
            .onReceive(viewModel.$enabled) { state in
                Redditweaks.defaults.setValue(state, forKey: viewModel.feature.name)
            }
    }

}
