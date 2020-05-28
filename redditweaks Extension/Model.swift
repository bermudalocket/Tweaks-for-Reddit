//
//  Model.swift
//  redditweaks Extension
//
//  Created by Michael Rippe on 5/28/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Foundation

class Model {

    lazy var features: [Feature: Bool] = {
        Feature.features.reduce(into: [:]) { agg, next in
            agg[next] = UserDefaults.standard.bool(forKey: next.name)
        }
    }()

    func changeFeatureState(_ feature: Feature, state: Bool) {
        features[feature] = state
        UserDefaults.standard.set(state, forKey: feature.name)
        SafariExtensionHandler.shared.sendScriptToSafariPage(feature)
    }

}
