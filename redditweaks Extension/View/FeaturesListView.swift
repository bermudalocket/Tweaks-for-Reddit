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
        appState.features.keys.lazy.filter {
            !$0.premium
        }.sorted {
            $0 < $1
        }
    }

    var body: some View {
        GroupBox(label: Text("Features")) {
            VStack(alignment: .leading) {
                ForEach(features, id: \.self) { feature in
                    Toggle(feature.description,
                           isOn: appState.bindingForFeature(feature))
                    if feature == .customSubredditBar && appState.bindingForFeature(feature).wrappedValue {
                        FavoriteSubredditsSectionView()
                            .environmentObject(appState)
                    }
                }
            }
            .padding([.top, .bottom, .leading], 10)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }

}

struct FeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesListView()
            .environmentObject(AppState.preview)
    }
}
