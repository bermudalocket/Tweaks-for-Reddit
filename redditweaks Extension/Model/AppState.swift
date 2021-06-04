//
//  AppState.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import Combine

enum FavoriteSubredditListHeight: Int, CaseIterable {
    case small = 125, medium = 200, large = 320

    var displayName: String {
        switch self {
            case .small: return "Small"
            case .medium: return "Medium"
            case .large: return "Large"
        }
    }
}

final class AppState: ObservableObject {

    @Published var features: [Feature: Bool] = {
        var map = [Feature: Bool]()
        Feature.features.forEach { feature in
            map[feature] = Redditweaks.defaults.bool(forKey: feature.key)
        }
        map[.liveCommentPreview] = Redditweaks.defaults.bool(forKey: "liveCommentPreview")
        return map
    }()

    public static let preview = AppState()

    final func bindingForFeature(_ feature: Feature) -> Binding<Bool> {
        .init(get: {
            self.features[feature] ?? false
        }, set: { bool in
            var copy = [Feature: Bool]()
            self.features.forEach { copy[$0] = $1 }
            copy[feature] = bool
            Redditweaks.defaults.setValue(bool, forKey: feature.key)
            self.features = copy
        })
    }

}
