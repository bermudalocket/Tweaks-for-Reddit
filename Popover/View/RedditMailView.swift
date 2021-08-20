//
//  RedditMailView.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/21/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

struct RedditMailView: View {

    @EnvironmentObject private var store: Store<RedditState, RedditAction, TFREnvironment>

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
                        if isHovering {
                            Image(systemName: "arrow.left.circle")
                        } else {
                            Image(systemName: message.subject == "post reply" ? "note.text" : "text.bubble")
                        }
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
            .contentShape(Rectangle())
            .onHover { isHovering = $0 }
            .onTapGesture {
                NSWorkspace.shared.open(URL(string: "https://www.reddit.com\(message.context)")!)
            }
        }
    }

    var body: some View {
        List {
            if let messages = store.state.unreadMessages {
                ForEach(messages.sorted(by: { $0.created > $1.created }), id: \.self) { message in
                    Row(message: message)
                    Divider()
                }
            } else {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .accessibilityLabel("Mail list")
        .onAppear {
            store.send(.checkForMessages)
        }
    }
}

import Combine

struct RedditMailView_Previews: PreviewProvider {
    static var previews: some View {
        RedditMailView()
            .frame(width: 300, height: 300)
            .environmentObject(
                Store<RedditState, RedditAction, TFREnvironment>(
                    initialState: .init(userData: nil, unreadMessages: [
                        UnreadMessage(author: "thebermudalocket",
                                      body: "you're a noob",
                                      subreddit: "lol",
                                      subject: "comment reply",
                                      context: "some url",
                                      created: Date().addingTimeInterval(-1*Double.random(in: 1000...100000)).timeIntervalSince1970
                                     ),
                        UnreadMessage(author: "Silversunset01",
                                      body: "lol",
                                      subreddit: "limeterracotta",
                                      subject: "post reply",
                                      context: "some url",
                                      created: Date().addingTimeInterval(-1*Double.random(in: 1000...100000)).timeIntervalSince1970
                                     ),
                        UnreadMessage(author: "Sir_Didymus",
                                      body: "oi you fucking lot where the fuck are you i swear on me mum i will find you and i will shove",
                                      subreddit: "limeterracotta",
                                      subject: "post reply",
                                      context: "some url",
                                      created: Date().addingTimeInterval(-1*Double.random(in: 1000...100000)).timeIntervalSince1970
                                     )
                    ]),
                    reducer: .none,
                    environment: .mock
                )
            )
    }
}
