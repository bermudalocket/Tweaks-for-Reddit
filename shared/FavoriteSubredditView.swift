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

    @EnvironmentObject private var appState: AppState

    let subreddit: String

    @State private var isHovered = false

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "newspaper")
            Text("r/\(subreddit)")
            if isHovered {
                Button("Open") {
                    NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(subreddit)")!)
                }
                .buttonStyle(LinkButtonStyle())
                .padding(.horizontal)
                Button {
                    appState.removeFavoriteSubreddit(subreddit: subreddit)
                } label: {
                    Text("Delete")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.horizontal, 5)
                .background(Color.red.opacity(0.05).cornerRadius(10))
            }
            Spacer()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }

}
