//
//  FeaturesListView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI

struct FeaturesListView: View {

    @EnvironmentObject private var store: ExtensionStore

    private var features: [Feature] {
        store.state.features.lazy.filter {
            !$0.premium
        }.sorted {
            $0 < $1
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(features, id: \.self) { feature in
                Toggle(feature.description, isOn: store.binding(for: feature))
                    .help(feature.help)
                    .accessibilityLabel(feature.description)
                if feature == .customSubredditBar && store.binding(for: feature).wrappedValue {
                    FavoriteSubredditsSectionView()
                }
            }
        }
        .padding([.top, .bottom, .leading], 10)
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

}

struct FeaturesListView_Preview: PreviewProvider {

    private static let store = ExtensionStore.mock

    static var previews: some View {
        FeaturesListView()
            .environmentObject(store)
    }
}
