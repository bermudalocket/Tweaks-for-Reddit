//
//  PopoverView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

struct PopoverView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 10) {
            TitleView()
                .padding(.vertical)
                .background(SectionBackgroundView())

            FeaturesListView()
                .environmentObject(appState)
                .padding(.horizontal)
                .background(SectionBackgroundView())
                .frame(alignment: .top)

            if appState.features[.customSubredditBar] ?? false {
                FavoriteSubredditsSectionView()
                    .padding()
                    .background(SectionBackgroundView())
            }

            SettingsView()
                .padding(.horizontal)
                .background(SectionBackgroundView())

            UpdateView()
        }
        .padding(10)
        .frame(width: 300, alignment: .top)
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopoverView()
                .environmentObject(AppState())
        }
    }
}
