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

    @Environment(\.managedObjectContext) private var viewContext

    let subreddit: FavoriteSubreddit

    @State private var isEditing = false
    @State private var subredditRenameField = ""

    private var imageName: String {
        switch subreddit.name?.uppercased() {
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
        guard let name = subreddit.name, let url = URL(string: "https://www.reddit.com/r/\(name)") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    func edit() {
        isEditing = true
    }

    func delete() {
        viewContext.delete(subreddit)
    }

    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            if isEditing {
                TextField("Subreddit", text: $subredditRenameField, onEditingChanged: { _ in }) {
                    subreddit.name = subredditRenameField
                    isEditing = false
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, alignment: .leading)
            } else {
                Menu("r/\(subreddit.name ?? "???")") {
                    Button("Open", action: openSubredditInBrowser)
                    Button("Edit", action: edit)
                    Divider()
                    Button(action: delete) {
                        Text("Delete").foregroundColor(.red)
                    }
                }
                .frame(width: 200, alignment: .leading)
                .menuStyle(BorderlessButtonMenuStyle())
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            self.subredditRenameField = self.subreddit.name ?? ""
        }
    }

}
