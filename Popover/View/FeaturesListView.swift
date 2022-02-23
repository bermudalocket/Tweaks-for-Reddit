//
//  FeaturesListView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI
import TFRCore

struct FeaturesListView: View {

    @EnvironmentObject private var store: PopoverStore

    private var features: [Feature] {
        store.state.features.lazy.filter {
            !$0.premium
        }.sorted {
            $0 < $1
        }
    }

    var body: some View {
        GroupBox(label: Text("Features")) {
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
            .padding(10)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }

}

struct FeaturesListView_Preview: PreviewProvider {
    static var previews: some View {
        FeaturesListView()
            .environmentObject(PopoverStore.preview)
            .frame(width: TweaksForReddit.popoverWidth)
    }
}
