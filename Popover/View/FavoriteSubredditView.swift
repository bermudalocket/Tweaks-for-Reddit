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
import TFRCore

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct FavoriteSubredditView: View {

    @EnvironmentObject private var store: PopoverStore

    let subreddit: FavoriteSubreddit

    @State private var isHovered = false

    private var icon: AnyView {
        if isHovered {
            return Image(systemName: "arrowshape.turn.up.left.fill")
                .eraseToAnyView()
        }
        guard let name = subreddit.name else {
            return Image(systemName: "questionmark").eraseToAnyView()
        }
        return Image(systemName: TweaksForReddit.symbolForSubreddit(name))
            .frame(width: 20)
            .eraseToAnyView()
    }

    var body: some View {
        HStack(alignment: .center) {
            self.icon
                .foregroundColor(.accentColor)
                .frame(width: 20)
                .onTapGesture(perform: subreddit.open)
            Menu("r/\(subreddit.name ?? "???")") {
                Button(action: subreddit.open) {
                    Text("Open")
                }
                Divider()
                Button(action: {
                    store.send(.deleteFavoriteSubreddit(self.subreddit))
                }) {
                    Text("Delete")
                        .foregroundColor(.red)
                }
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
