//
//  PopoverView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import SwiftUI

struct PopoverView: View {

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .foregroundColor(Color(.controlBackgroundColor))
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("redditweaks")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                Spacer()
            }
            Text("v\(self.version)")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .padding(.top, 4)
        .background(sectionBackground)
    }

    private var featuresList: some View {
        VStack(alignment: .leading) {
            ForEach(Feature.sortedFeatures, id: \.self) { feature in
                FeatureToggleView(feature: feature)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(sectionBackground)
    }

    @State private var favoriteSubreddits: [String] = Redditweaks.favoriteSubreddits

    @State private var newFavoriteSubredditField: String = "r/"

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                self.title
                self.featuresList
                VStack(alignment: .leading) {
                    HStack {
                        TextField("r/", text: $newFavoriteSubredditField)
                        if #available(OSXApplicationExtension 10.16, *) {
                            Button("Add", action: {
                                Redditweaks.addFavoriteSubreddit(&newFavoriteSubredditField)
                            }).keyboardShortcut(.return)
                        } else {
                            Button("Add", action: {
                                Redditweaks.addFavoriteSubreddit(&newFavoriteSubredditField)
                            })
                        }
                    }
                    ForEach(favoriteSubreddits, id: \.self) { favoriteSubreddit in
                        FavoriteSubredditView(favoriteSubreddit: favoriteSubreddit)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .frame(width: 300, height: 500)
        .onReceive(Redditweaks.favoriteSubredditsPublisher) { favs in
            self.favoriteSubreddits = favs
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
