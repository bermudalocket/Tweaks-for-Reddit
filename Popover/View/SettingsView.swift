//
//  SettingsView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import Composable_Architecture
import TFRCore

struct SettingsView: View {

    @EnvironmentObject private var store: Store<PopoverState, PopoverAction, TFREnvironment>

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Favorites display size")
                    .frame(minWidth: 0, maxWidth: .infinity)
                Picker(selection: store.binding(for: \.favoriteSubredditListHeight, transform: PopoverAction.setFavoriteSubredditsListHeight(height:)),
                       label: EmptyView()
                ) {
                    ForEach(FavoriteSubredditListHeight.allCases, id: \.self) { height in
                        Button(height.displayName) {
                            store.send(.setFavoriteSubredditsListHeight(height: height))
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .contentShape(Rectangle())
            .help("Determines how many subreddits are visible in the Favorite Subreddits list")
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(5)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .frame(width: TweaksForReddit.popoverWidth)
            .environmentObject(PopoverStore.shared)
    }
}
