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
    enclosingScrollView?.drawsBackground = false
  }
}

struct FavoriteSubredditsSectionView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var appState: AppState

    @State private var favoriteSubredditField = ""
    @State private var isSearching = false
    @State private var isSubredditValid = false

    @FetchRequest(entity: FavoriteSubreddit.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \FavoriteSubreddit.name, ascending: true)
    ], predicate: nil) private var favoriteSubreddits: FetchedResults<FavoriteSubreddit>

    func addFavoriteSub() {
        guard !favoriteSubreddits.compactMap(\.name).contains(favoriteSubredditField) else {
            return
        }
        let sub = FavoriteSubreddit(context: viewContext)
        sub.name = favoriteSubredditField
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                TextField("r/", text: $favoriteSubredditField) { _ in
                    appState.verifySubreddit(subreddit: favoriteSubredditField,
                                             isValid: $isSubredditValid,
                                             isSearching: $isSearching)
                } onCommit: {
                    addFavoriteSub()
                }
                .foregroundColor(isSubredditValid ? .black : .red)
                if isSearching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.5)
                }
            }
            List {
                ForEach(favoriteSubreddits, id: \.self) {
                    FavoriteSubredditView(subreddit: $0)
                }
                .onMove(perform: onMove)
            }
            .listStyle(PlainListStyle())
            .focusable()
            .frame(height: 25 * CGFloat(favoriteSubreddits.count))
        }
    }

    private func onMove(indices: IndexSet, newOffset: Int) {
        // TODO
//        favoriteSubreddits.move(fromOffsets: indices, toOffset: newOffset)
    }
}

struct FavoriteSubredditsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditsSectionView()
            .environmentObject(AppState.preview)
    }
}
