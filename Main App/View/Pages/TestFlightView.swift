//
//  TestFlightView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 8/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCore

struct TestFlightView: View {

    @EnvironmentObject private var store: MainAppStore

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(spacing: 10) {
                Image(systemName: SelectedTab.testFlight.symbol)
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
                Text(SelectedTab.testFlight.name)
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.horizontal)

            Text("If you're on macOS 12 and are interested in testing beta versions\nof Tweaks for Reddit, check out our TestFlight program.")
                .fixedSize(horizontal: true, vertical: true)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "1.circle")
                        .imageScale(.large)
                        .foregroundColor(.redditOrange)
                    Text("Be a developer running the macOS 12 developer beta.")
                }
                HStack {
                    Image(systemName: "2.circle")
                        .imageScale(.large)
                        .foregroundColor(.redditOrange)
                    Text("Download TestFlight for macOS 12 via Apple's Developer portal.")
                }
                HStack(alignment: .top) {
                    Image(systemName: "3.circle")
                        .imageScale(.large)
                        .foregroundColor(.redditOrange)
                    (Text("Click the button below to open Safari which will redirect you to TestFlight.\n") + Text("If nothing happens, try opening the URL in Safari Technology Preview.").italic())
                        .fixedSize(horizontal: true, vertical: true)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundColor(Color(.textBackgroundColor))
            )

            HStack {
                Button("Open in Safari \(Image(systemName: "safari.fill"))") {
                    store.send(.openTestFlight)
                }.buttonStyle(RedditweaksButtonStyle())
            }
        }.onAppear {
            store.send(.checkNotificationsEnabled)
        }
    }

}

struct TestFlightView_Preview: PreviewProvider {
    static var previews: some View {
        TestFlightView()
            .environmentObject(MainAppStore.init(initialState: MainAppState(), reducer: .none, environment: .shared))
            .padding()
    }
}
