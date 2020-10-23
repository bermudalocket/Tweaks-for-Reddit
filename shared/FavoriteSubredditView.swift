//
//  FavoriteSubredditView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/8/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import SwiftUI

struct FavoriteSubredditView: View {

    let favoriteSubreddit: String

    @State private var isHovered = false

    var body: some View {
        HStack {
            Text("r/\(favoriteSubreddit)")
            Image("heart.slash.fill")
                .foregroundColor(.pink)
                .opacity(isHovered ? 1 : 0)
                .onTapGesture {
                    Redditweaks.removeFavoriteSubreddit(favoriteSubreddit)
                }
            Image("square.and.arrow.up")
                .foregroundColor(.blue)
                .opacity(isHovered ? 1 : 0)
                .onTapGesture {
                    NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(favoriteSubreddit)")!)
                }
            Spacer()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }

}
