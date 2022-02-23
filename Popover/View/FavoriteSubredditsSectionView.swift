//
//  FavoriteSubredditsSectionView.swift
//  Tweaks for Reddit Extension
//  5.0
//  10.16
//
//  Created by Michael Rippe on 7/9/20.
//  Copyright © 2020 Michael Rippe. All rights reserved.
//

import Combine
import SwiftUI
import TFRCore

// TODO
// https://stackoverflow.com/questions/60454752/swiftui-background-color-of-list-mac-os
extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView?.drawsBackground = false
  }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}

struct FavoriteSubredditsSectionView: View {

    @EnvironmentObject private var store: PopoverStore

    @State private var favoriteSubredditField = ""

    @State private var isShowingError: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Menu("Sorting \(store.state.favoriteSubredditListSortingMethod.description)") {
                    ForEach(FavoriteSubredditSortingMethod.allCases, id: \.self) { method in
                        Button("Sort \(method.description)") {
                            store.send(.setFavoriteSubredditSortingMethod(method: method))
                        }
                    }
                }
                Menu("Showing \(store.state.favoriteSubredditListHeight.displayName)") {
                    ForEach(FavoriteSubredditListHeight.allCases, id: \.self) { listHeight in
                        Button("Show \(listHeight.displayName)") {
                            store.send(.setFavoriteSubredditsListHeight(height: listHeight))
                        }
                    }
                }
            }
            TextField("r/", text: $favoriteSubredditField, onCommit: {
                if favoriteSubredditField == "" {
                    withAnimation(.default) {
                        isShowingError += 1
                    }
                    return
                }
                store.send(.addFavoriteSubreddit(favoriteSubredditField))
                favoriteSubredditField = ""
            })
                .modifier(Shake(animatableData: CGFloat(isShowingError)))
            Group {
                if store.state.favoriteSubredditListSortingMethod == .alphabetical {
                    List(store.state.favoriteSubreddits.sorted { $0.name! < $1.name! }, rowContent: FavoriteSubredditView.init(subreddit:))
                } else {
                    List {
                        ForEach(store.state.favoriteSubreddits.sorted { $0.position < $1.position }) {
                            FavoriteSubredditView(subreddit: $0)
                        }
                        .onMove { indices, newOffset in
                            store.send(.moveFavoriteSubreddit(indices: indices, newOffset: newOffset))
                        }
                    }
                }
            }
            .transition(.opacity.animation(.default))
            .listStyle(PlainListStyle())
            .frame(height: min(
                CGFloat(store.state.favoriteSubredditListHeight.rawValue),
                25 * CGFloat(store.state.favoriteSubreddits.count)
            ))

        }
    }

}

struct FavoriteSubredditsSectionView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteSubredditsSectionView()
            .environmentObject(PopoverStore.preview)
            .frame(width: TweaksForReddit.popoverWidth)
            .padding()
    }
}
