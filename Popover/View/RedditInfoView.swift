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

    @State private var isHoveringOverMailButton = false

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
                        VStack {
                            Text("No tokens were found.\nPlease re-authorize in the main app.")
                                .multilineTextAlignment(.center)
                            Button("Open Tweaks for Reddit") {
                                NSWorkspace.shared.open(URL(string: "rdtwks://")!)
                            }
                        }

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

                    RedditRowView(isPopoverPresented: .constant(false)) {
                        Image(systemName: "note.text")
                            .frame(width: 20)
                        Text("\(postKarma)")
                            .accessibilityLabel("\(postKarma) post karma")
                    }

                    RedditRowView(isPopoverPresented: .constant(false)) {
                        Image(systemName: "text.bubble")
                            .frame(width: 20)
                        Text("\(commentKarma)")
                            .accessibilityLabel("\(commentKarma) comment karma")
                    }

                    RedditRowView(isPopoverPresented: $isShowingHiddenPostsView) {
                        Image(systemName: "eye.slash")
                            .frame(width: 20)
                        Text("Hidden posts")
                    }

                    RedditRowView(isPopoverPresented: $store.state.isShowingMailView) {
                        self.inboxSymbol
                            .frame(width: 20)
                        Text("\(inboxCount) new message\(inboxCount > 1 ? "s" : "")")
                            .accessibilityLabel("\(inboxCount) new messages")
                    }
                } // VStack
            }
        } // HStack
        .onAppear {
            store.send(.fetchUserData)
        }
    } // body

    private struct RedditRowView<Content: View>: View {

        let content: Content

        var popoverBinding: Binding<Bool>

        @State private var isHovering = false

        init(isPopoverPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
            self.content = content()
            self.popoverBinding = isPopoverPresented
        }

        var body: some View {
            HStack {
                content
                Spacer()
                Image(systemName: "chevron.right")
                    .padding(.horizontal)
            }
                .padding(2.5)
                .contentShape(RoundedRectangle(cornerRadius: 5))
                .onHover { isHovering = $0 }
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(
                            isHovering ? Color.redditOrange.opacity(0.33) : Color.clear
                        )
                        .padding(.trailing, 5)
                )
                .onTapGesture { popoverBinding.wrappedValue.toggle() }
                .popover(isPresented: popoverBinding, attachmentAnchor: .rect(.bounds), arrowEdge: .trailing) {
                    RedditMailView()
                        .frame(width: 400)
                }
        }
    }

}
