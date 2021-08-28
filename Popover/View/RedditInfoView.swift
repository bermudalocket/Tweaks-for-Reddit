//
//  RedditInfoView.swift
//  redditweaks
//
//  Created by Michael Rippe on 6/20/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import Foundation
import SwiftUI
import Composable_Architecture
import Tweaks_for_Reddit_Core

struct RedditInfoView: View {

    @EnvironmentObject private var store: RedditStore

    private var postKarma: Int? {
        store.state.userData?.postKarma
    }

    private var commentKarma: Int? {
        store.state.userData?.commentKarma
    }

    private var hasMail: Bool {
        store.state.userData?.hasMail ?? false
    }

    @State private var isShowingMailView = false

    var body: some View {
        if store.state.isShowingOAuthError, let error = store.state.error {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(width: 40)
                    .foregroundColor(.red)
                Text(error)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
                Button("Open Tweaks for Reddit") {
                    NSWorkspace.shared.open(URL(string: "rdtwks://auth")!)
                }
            }
        } else {
            HStack(alignment: .center) {
                if let url = store.state.userData?.snoovatarUrl {
                    AsyncImage(
                        url: url,
                        fallbackSymbol: "xmark.octagon.fill"
                    )
                        .scaleEffect(0.8)
                }
                VStack(alignment: .leading, spacing: 5) {
                    if let username = store.state.userData?.username {
                        Text("u/\(username)")
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
                        if let postKarma = postKarma {
                            Text("\(postKarma)")
                                .accessibilityLabel("Post karma")
                        } else {
                            Text("1,234")
                                .redacted(reason: .placeholder)
                                .accessibilityLabel("Post karma is loading")
                        }
                    }
                    HStack {
                        Image(systemName: "text.bubble")
                        if let commentKarma = commentKarma {
                            Text("\(commentKarma)")
                                .accessibilityLabel("Comment karma")
                        } else {
                            Text("12,345")
                                .redacted(reason: .placeholder)
                                .accessibilityLabel("Comment karma is loading")
                        }
                    }
                    HStack {
                        Button(action: {
                            isShowingMailView.toggle()
                        }, label: {
                            Image(systemName: "envelope\(hasMail ? ".badge" : "")")
                                .foregroundColor(hasMail ? .accentColor : .gray)
                        })
                            .disabled(!hasMail)
                            .buttonStyle(PlainButtonStyle())
                            .popover(isPresented: $isShowingMailView) {
                                RedditMailView()
                                    .frame(width: 400)
                            }
                            .accessibilityLabel("Mail button")
                        Text(hasMail ? "New mail" : "No new mail")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }.padding(.top)
                }
                .font(.system(.title2, design: .rounded).bold())
            }.onAppear {
                store.send(.fetchUserData)
            }
        }
    }

}

struct RedditInfoViewPreview: PreviewProvider {
    static var previews: some View {
        RedditInfoView()
            .environmentObject(
                ExtensionStore.mock.derived(
                    deriveState: \.redditState,
                    deriveAction: ExtensionAction.reddit
                )
            )
            .frame(width: TweaksForReddit.popoverWidth)
    }
}
