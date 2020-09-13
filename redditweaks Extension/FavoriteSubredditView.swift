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

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .foregroundColor(isHovered ? .accentColor : Color(.controlBackgroundColor))
    }

    var body: some View {
        HStack {
            Text("⊕")
                .foregroundColor(.blue)
                .opacity(isHovered ? 1 : 0)
                .onTapGesture {
                    if self.isHovered {
                        Redditweaks.removeFavoriteSubreddit(self.favoriteSubreddit)
                    }
                }
            Text("r/\(favoriteSubreddit)")
            Spacer()
        }
        .onHover { hovering in
            self.isHovered = hovering
        }
    }

}
