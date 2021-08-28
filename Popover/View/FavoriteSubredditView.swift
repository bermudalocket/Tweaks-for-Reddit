//
//  FavoriteSubredditView.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/8/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import SwiftUI
import Tweaks_for_Reddit_Core

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct FavoriteSubredditView: View {

    @EnvironmentObject private var store: ExtensionStore

    let subreddit: FavoriteSubreddit

    @State private var isHovered = false

    let sfSymbolsMap: [String: String] = [
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

    let emojiMap: [String: String] = [
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
        if isHovered {
            return Image(systemName: "arrowshape.turn.up.left.fill")
                .eraseToAnyView()
        }
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

    var body: some View {
        HStack(alignment: .center) {
            self.icon
                .foregroundColor(.accentColor)
                .frame(width: 20)
                .onTapGesture {
                    store.send(.openFavoriteSubreddit(subreddit))
                }
            Menu("r/\(subreddit.name ?? "???")") {
                Button("Open") {
                    store.send(.openFavoriteSubreddit(subreddit))
                }
                Divider()
                Button(action: {
                    store.send(.deleteFavoriteSubreddit(self.subreddit))
                }, label: {
                    Text("Delete")
                        .foregroundColor(.red)
                })
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .contentShape(Rectangle())
        .onHover {
            self.isHovered = $0
        }
    }

}
