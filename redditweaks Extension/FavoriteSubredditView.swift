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
            if #available(OSXApplicationExtension 10.16, *) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .opacity(isHovered ? 1 : 0)
                    .onTapGesture {
                        if isHovered {
                            Redditweaks.removeFavoriteSubreddit(favoriteSubreddit)
                        }
                    }
            } else {
                // Fallback on earlier versions
            }
            Text("r/\(favoriteSubreddit)")
            Spacer()
        }
        .onHover { hovering in
            self.isHovered = hovering
        }
    }

}
