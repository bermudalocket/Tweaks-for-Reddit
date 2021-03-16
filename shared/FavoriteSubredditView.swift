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

    @State private var isEditing = false
    @State private var subredditRenameField = ""

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

    func openSubredditInBrowser() {
        NSWorkspace.shared.open(URL(string: "https://www.reddit.com/r/\(subreddit)")!)
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            if isEditing {
                TextField("Subreddit", text: $subredditRenameField, onEditingChanged: { _ in }) {
                    guard let index = appState.favoriteSubreddits.firstIndex(of: subreddit) else {
                        return
                    }
                    appState.favoriteSubreddits[index] = subredditRenameField
                    isEditing = false
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, alignment: .leading)
            } else {
                Menu("r/\(subreddit)") {
                    Button("Open", action: openSubredditInBrowser)
                    Button("Edit") { isEditing = true }
                    Divider()
                    Button {
                        appState.removeFavoriteSubreddit(subreddit: subreddit)
                    } label: {
                        Text("Delete").foregroundColor(.red)
                    }
                }
                .frame(width: 200, alignment: .leading)
                .menuStyle(BorderlessButtonMenuStyle())
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            self.subredditRenameField = self.subreddit
        }
    }

}

struct FavoriteSubredditViewPreview: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditView(subreddit: "macos")
            .environmentObject(AppState.preview)
    }
}
