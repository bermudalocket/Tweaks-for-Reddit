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

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct FavoriteSubredditView: View {

    @Environment(\.managedObjectContext) private var viewContext

    let subreddit: FavoriteSubreddit

    @State private var isEditing = false
    @State private var subredditRenameField = ""

    public let sfSymbolsMap: [String: String] = [
        "apple": "applelogo",
        "art": "paintbrush.fill",
        "books": "books.vertical.fill",
        "consulting": "rectangle.3.offgrid.bubble.left.fill",
        "earthporn": "globe",
        "explainlikeimfive": "questionmark.circle.fill",
        "gaming": "gamecontroller.fill",
        "math": "function",
        "movies": "film.fill",
        "music": "music.quarternote.3",
        "news": "newspaper.fill",
        "pics": "photo.fill",
        "photography": "photo.fill",
        "space": "moon.stars.fill",
        "sports": "sportscourt.fill",
        "television": "tv.fill",
        "todayilearned": "lightbulb.fill",
        "worldnews": "newspaper.fill",

        // apple products
        "iphone": "iphone",
        "ipad": "ipad",
        "ipados": "ipad",
        "ipadosbeta": "ipad",
        "macos": "desktopcomputer",
        "macosbeta": "desktopcomputer",
        "ios": "ipad",
        "iosbeta": "ipad",
        "homepod": "homepod.fill",
    ]

    public let emojiMap: [String: String] = [
        "jokes": "😂",
        "phasmophobiagame": "👻",
        "science": "🔬",
        "askscience": "🧬",
        "funny": "🎭",
        "showerthoughts": "🚿",
        "nyc": "🏙️",

        // sports
        "soccer": "⚽",
        "basketball": "🏀",
        "football": "🏈",
        "rugby": "🏉",
    ]

    private let defaultIcon = Image(systemName: "doc")

    private var icon: AnyView {
        guard let name = subreddit.name else {
            return defaultIcon.eraseToAnyView()
        }
        if let symbolName = sfSymbolsMap[name] {
            return Image(systemName: symbolName)
                .frame(width: 20)
                .eraseToAnyView()
        } else if let emoji = emojiMap[name] {
            return Text(emoji)
                .drawingGroup()
                .frame(width: 20)
                .eraseToAnyView()
        } else {
            return defaultIcon.eraseToAnyView()
        }
    }

    func openSubredditInBrowser() {
        guard let name = subreddit.name, let url = URL(string: "https://www.reddit.com/r/\(name)") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    var body: some View {
        HStack(alignment: .center) {
            self.icon
                .foregroundColor(.accentColor)
                .frame(width: 20)
                .onTapGesture(perform: openSubredditInBrowser)
            if isEditing {
                TextField("Subreddit", text: $subredditRenameField, onEditingChanged: { _ in }) {
                    subreddit.name = subredditRenameField
                    isEditing = false
                }
                .focusable()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200, alignment: .leading)
            } else {
                Menu("r/\(subreddit.name ?? "???")") {
                    Button("Open", action: openSubredditInBrowser)
                    Button("Edit") { isEditing = true }
                    Divider()
                    Button(action: { viewContext.delete(subreddit) }) {
                        Text("Delete").foregroundColor(.red)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .menuStyle(BorderlessButtonMenuStyle())
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            self.subredditRenameField = self.subreddit.name ?? ""
        }
    }

}
