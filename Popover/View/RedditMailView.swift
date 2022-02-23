//
//  RedditMailView.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCompose
import TFRCore

struct RedditMailView: View {

    @EnvironmentObject private var store: RedditStore

    struct Row: View {
        @Environment(\.calendar) private var calendar
        let message: UnreadMessage
        @State private var isHovering = false
        private var dateFormatter: RelativeDateTimeFormatter {
            let fmt = RelativeDateTimeFormatter()
            fmt.calendar = calendar
            return fmt
        }
        var body: some View {
            HStack(spacing: 0) {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: message.subject == "post reply" ? "note.text" : "text.bubble")
                        Text("u/" + message.author).bold()
                    }
                    Text(message.body)
                        .lineLimit(3)
                        .truncationMode(.tail)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing) {
                    Text("\(message.createdTimestamp, formatter: dateFormatter)")
                        .font(.callout)
                        .foregroundColor(Color(.placeholderTextColor))
                    Text("in r/\(message.subreddit)")
                        .font(.footnote)
                        .foregroundColor(Color(.placeholderTextColor))
                }
            }
            .padding()
            .contentShape(Rectangle())
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .foregroundColor(isHovering ? .accentColor : .clear)
                    .opacity(0.25)
            )
            .onHover { isHovering = $0 }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://www.reddit.com\(message.context)")!)
            }
        }
    }

    var body: some View {
        if let messages = store.state.unreadMessages {
            if messages.count > 0 {
                ForEach(messages.sorted { $0.created > $1.created }, id: \.self) { message in
                    Row(message: message)
                }
                .accessibilityLabel("Mail list")
                .frame(height: 80)
                .padding(.horizontal)
            } else {
                Text("No new messages.")
                    .padding()
            }
        } else {
            ProgressView()
                .scaleEffect(0.5)
                .accessibilityLabel("Mail is loading")
                .onAppear {
                    store.send(.checkForMessages)
                }
        }
    }
}

import Combine

struct RedditMailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RedditMailView()
                .environmentObject(PopoverStore.preview)
            RedditMailView()
                .environmentObject(PopoverStore(
                    initialState: PopoverState(
                        redditState: RedditState(
                            isShowingMailView: true,
                            userData: .mock,
                            unreadMessages: [
                                UnreadMessage(author: "author", body: "body", subreddit: "subreddit", subject: "subject", context: "context", created: Date().timeIntervalSince1970 - 60*Double.random(in: 50...500)),
                                UnreadMessage(author: "author", body: "body", subreddit: "subreddit", subject: "subject", context: "context", created: Date().timeIntervalSince1970 - 60*Double.random(in: 50...500)),
                                UnreadMessage(author: "author", body: "body", subreddit: "subreddit", subject: "subject", context: "context", created: Date().timeIntervalSince1970 - 60*Double.random(in: 50...500)),
                                UnreadMessage(author: "author", body: "body", subreddit: "subreddit", subject: "subject", context: "context", created: Date().timeIntervalSince1970 - 60*Double.random(in: 50...500)),
                            ],
                            oauthError: nil
                        ),
                        isShowingWhatsNew: false,
                        features: Feature.features,
                        favoriteSubreddits: [],
                        favoriteSubredditListSortingMethod: .alphabetical,
                        favoriteSubredditListHeight: .medium
                    ),
                    reducer: popoverReducer,
                    environment: .shared
                ))
        }
            .frame(width: 300, height: 300)
            .environment(\.calendar, .current)
    }
}
