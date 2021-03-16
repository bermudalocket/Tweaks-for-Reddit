//
//  FavoriteSubredditsSectionView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/9/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

// TODO
// https://stackoverflow.com/questions/60454752/swiftui-background-color-of-list-mac-os
extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

struct FavoriteSubredditsSectionView: View {

    @EnvironmentObject private var appState: AppState

    @State private var favoriteSubredditField = ""
    @State private var isSearching = false
    @State private var isSubredditValid = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                TextField("r/", text: $favoriteSubredditField)
                    .foregroundColor(isSubredditValid ? .black : .red)
                    .onChange(of: favoriteSubredditField) {
                        appState.verifySubreddit(subreddit: $0, isValid: $isSubredditValid, isSearching: $isSearching)
                    }
                    .focusable(false)
                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.5)
                } else {
                    Button("Add") {
                        appState.addFavoriteSubreddit(subreddit: favoriteSubredditField)
                    }
                    .disabled(!isSubredditValid)
                }
            }
            List {
                ForEach(appState.favoriteSubreddits, id: \.self) {
                    FavoriteSubredditView(subreddit: $0)
                }
                .onMove(perform: onMove)
            }
            .listStyle(PlainListStyle())
            .frame(height: 25 * CGFloat(appState.favoriteSubreddits.count))
        }
    }

    private func onMove(indices: IndexSet, newOffset: Int) {
        appState.favoriteSubreddits.move(fromOffsets: indices, toOffset: newOffset)
    }
}

struct FavoriteSubredditsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditsSectionView()
            .environmentObject(AppState.preview)
    }
}
