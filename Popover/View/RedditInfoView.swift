//
//  RedditInfoView.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI
import TFRCore
import Kingfisher

struct RedditInfoView: View {

    @EnvironmentObject private var store: RedditStore

    /// A NumberFormatter that adds thousands separators
    private var decimalFormatter: NumberFormatter {
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.hasThousandSeparators = true
        return fmt
    }

    private var postKarma: String {
        if let karma = store.state.userData?.postKarma, let fmt = decimalFormatter.string(from: NSNumber(value: karma)) {
            return "\(fmt)"
        } else {
            return "-"
        }
    }

    private var commentKarma: String {
        if let karma = store.state.userData?.commentKarma, let fmt = decimalFormatter.string(from: NSNumber(value: karma)) {
            return "\(fmt)"
        } else {
            return "-"
        }
    }

    private var inboxCount: Int {
        store.state.userData?.inboxCount ?? 0
    }

    private var inboxSymbol: some View {
        if inboxCount > 0 {
            return Image(systemName: "envelope.circle.fill")
                .foregroundColor(.accentColor)
        }
        return Image(systemName: "envelope.circle.fill")
            .foregroundColor(Color(.placeholderTextColor))
    }

    @State private var isShowingHiddenPostsView = false

    var body: some View {
        HStack(alignment: .center) {
            if let error = store.state.oauthError {
                switch error {
                    case .noToken:
                        Text("No tokens were found.\nPlease re-authorize in the main app.")
                            .multilineTextAlignment(.center)

                    case .unauthorized:
                        Text("Unauthorized")

                    case .badResponse(code: let code):
                        Text("HTTP error \(code ?? -1)")

                    case .downloadFailed:
                        Text("Internal error")

                    case .wrapping(message: let msg):
                        Text(msg)
                }
            } else {
                if let url = store.state.userData?.snoovatarUrl {
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.5)
                        .padding(20)
                }
                VStack(alignment: .leading, spacing: 5) {
                    if let username = store.state.userData?.username {
                        (Text("u/") + Text(username).bold())
                            .font(.title3)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Username")
                    } else {
                        Text("u/abcdefghijk")
                            .redacted(reason: .placeholder)
                    }
                    HStack {
                        Image(systemName: "note.text")
                            .frame(width: 20)
                        Text("\(postKarma)")
                            .accessibilityLabel("\(postKarma) post karma")
                        Spacer()
                        Button("\(Image(systemName: "chevron.right"))") {
                            store.send(.openPostHistory)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .disabled(store.state.userData?.postKarma == nil)
                        .padding(.horizontal)
                    }
                    HStack {
                        Image(systemName: "text.bubble")
                            .frame(width: 20)
                        Text("\(commentKarma)")
                            .accessibilityLabel("\(commentKarma) comment karma")
                        Spacer()
                        Button("\(Image(systemName: "chevron.right"))") {
                            store.send(.openCommentHistory)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .disabled(store.state.userData?.commentKarma == nil)
                        .padding(.horizontal)
                    }
                    HStack {
                        Image(systemName: "eye.slash")
                            .frame(width: 20)
                        Text("Hidden posts")
                        Spacer()
                        Button("\(Image(systemName: "chevron.right"))") {
                            isShowingHiddenPostsView.toggle()
                            store.send(.fetchHiddenPosts())
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .padding(.horizontal)
                        .popover(isPresented: $isShowingHiddenPostsView, attachmentAnchor: .rect(.bounds), arrowEdge: .leading) {
                            HiddenPostsView()
                        }
                    }
                    HStack {
                        self.inboxSymbol
                            .frame(width: 20)
                        Text("\(inboxCount) new message\(inboxCount > 1 ? "s" : "")")
                            .accessibilityLabel("\(inboxCount) new messages")
                        Spacer()
                        Button("\(Image(systemName: "chevron.right"))") {
                            store.send(.setIsShowingMailView(true))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .foregroundColor(Color(NSColor.placeholderTextColor))
                        .padding(.horizontal)
                        .popover(isPresented: $store.state.isShowingMailView, attachmentAnchor: .rect(.bounds), arrowEdge: .trailing) {
                            RedditMailView()
                                .frame(width: 400)
                        }
                    }
                } // VStack
            }
        } // HStack
        .onAppear {
            store.send(.fetchUserData)
        }
    } // body

}
