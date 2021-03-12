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

    private var imageName: String {
        switch subreddit.uppercased() {
            case "APPLE":
                return "applelogo"

            case "ASKREDDIT":
                return "person.fill.questionmark"

            case "GAMING":
                return "gamecontroller.fill"

            case "PICS":
                return "camera.fill"

            case "MATH":
                return "function"

            default:
                return "doc"
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: isHovered ? "xmark" : imageName)
                .foregroundColor(isHovered ? .red : .accentColor)
                .padding(2.5)
                .frame(width: 25)
                .onTapGesture {
                    if isHovered {
                        appState.removeFavoriteSubreddit(subreddit: subreddit)
                    }
                }
            Text("r/\(subreddit)")
                .lineLimit(1)
                .frame(width: 200, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .frame(height: 25)
        .onTapGesture(count: 2) {
            NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(subreddit)")!)
        }
    }

}

struct FavoriteSubredditViewPreview: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditView(subreddit: "politics")
            .environmentObject(AppState())
        FavoriteSubredditView(subreddit: "macos")
            .environmentObject(AppState())
        VStack {
            ForEach(["politics", "askreddit", "macos", "ios", "apple", "mildlyinteresting"], id: \.self) { sub in
                FavoriteSubredditView(subreddit: sub)
                    .environmentObject(AppState())
            }
        }
    }
}
