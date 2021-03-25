//
//  FeaturesListView.swift
//  redditweaks
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct FeaturesListView: View {

    @EnvironmentObject private var appState: AppState

    private var features: [Feature] {
        appState.features.keys.lazy.compactMap {
            ($0 == .nsfwFilter && appState.isFromMacAppStore) ? nil : $0
        }
    }

    var body: some View {
        GroupBox(label: Text("Features")) {
            VStack(alignment: .leading) {
                ForEach(features.sorted { $0 < $1 }, id: \.self) { feature in
                    Toggle(feature.description, isOn: appState.bindingForFeature(feature))
                        .lineLimit(2)
                    if feature == .customSubredditBar && appState.bindingForFeature(feature).wrappedValue {
                        FavoriteSubredditsSectionView()
                            .environmentObject(appState)
                    }
                }
            }
            .padding(10)
        }
    }

}

struct FeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesListView()
            .environmentObject(AppState())
            .frame(width: 300)
    }
}
