//
//  HiddenPostsView.swift
//  HiddenPostsView
//
//  Created by Michael Rippe on 9/12/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCore

struct HiddenPostsView: View {

    @EnvironmentObject private var store: RedditStore
    
    var body: some View {
        VStack {
            if store.state.hiddenPosts == nil {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Fetching...")
                    Spacer()
                }
            } else {
                List(store.state.hiddenPosts!, id: \.self) { post in
                    ZStack {
                        if store.state.postsBeingUnhidden.contains(post) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .imageScale(.small)
                        }
                        PostView(post: post)
                    }
                }
            }
            HStack {
                Button("\(Image(systemName: "arrow.clockwise"))") {
                    store.send(.fetchHiddenPosts())
                }
                .scaleEffect(0.8)
                .buttonStyle(RedditweaksButtonStyle())
                .padding([.bottom, .leading], 5)
                Button("\(Image(systemName: "arrow.left"))") {
                    if let first = store.state.hiddenPosts?.first {
                        store.send(.fetchHiddenPosts(before: first))
                    }
                }
                .scaleEffect(0.8)
                .buttonStyle(RedditweaksButtonStyle())
                .disabled(store.state.hiddenPosts == nil || store.state.hiddenPostsPage == 1)
                .padding(.bottom, 5)
                Spacer()
                Text("Page \(store.state.hiddenPostsPage)")
                Spacer()
                Button("\(Image(systemName: "arrow.right"))") {
                    if let last = store.state.hiddenPosts?.last {
                        store.send(.fetchHiddenPosts(after: last))
                    }
                }
                .scaleEffect(0.8)
                .buttonStyle(RedditweaksButtonStyle())
                .disabled(store.state.hiddenPosts == nil)
                .padding(.bottom, 5)
                Button("Unhide all") {
                    if let posts = store.state.hiddenPosts {
                        store.send(.unhidePosts(posts))
                    }
                }
                .scaleEffect(0.8)
                .buttonStyle(RedditweaksButtonStyle())
                .disabled(store.state.hiddenPosts == nil)
                .padding([.bottom, .trailing], 5)
            }
        }
            .frame(width: 400, height: 400)
            .transition(.opacity.animation(.easeInOut))
    }
}

struct HiddenPostsView_Previews: PreviewProvider {
    private static let store = RedditStore(
        initialState: RedditState(hiddenPosts: nil),
        reducer: redditReducer,
        environment: .shared
    )
    static var previews: some View {
        HiddenPostsView()
            .environmentObject(store)
    }
}
