//
//  PostView.swift.swift
//  PostView.swift
//
//  Created by Michael Rippe on 9/12/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCore

struct PostView: View {

    @EnvironmentObject private var store: RedditStore

    let post: Post

    private struct XButtonStyle: ButtonStyle {
        @State private var isHovered = false
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .buttonStyle(BorderlessButtonStyle())
                .contentShape(Rectangle())
                .onHover { isHovered = $0 }
                .foregroundColor(isHovered ? .red : Color(.placeholderTextColor))
                .scaleEffect(isHovered ? 1.0 : 1.15)
        }
    }

    var body: some View {
        HStack {
            Button("\(Image(systemName: "chevron.left"))") {
                NSWorkspace.shared.open(URL(string: "https://www.reddit.com\(post.permalink)")!)
            }
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(Color(.placeholderTextColor))
            VStack(alignment: .leading) {
                Text(post.title).lineLimit(2)
                Text("in r/") + Text(post.subreddit).bold()
            }
            Spacer()
            Button("\(Image(systemName: "xmark"))") {
                store.send(.unhidePosts([post]))
            }
            .buttonStyle(XButtonStyle())
        }
            .opacity(store.state.postsBeingUnhidden.contains(post) ? 0.33 : 1.0)
            .blur(radius: store.state.postsBeingUnhidden.contains(post) ? 1.5 : 0.0)
    }
}

//struct PostView_swift_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView(post: Post())
//    }
//}
