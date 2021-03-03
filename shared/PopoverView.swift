//
//  PopoverView.swift
//  redditweaks Extension
//  5.0
//  10.16
//
//  Created by bermudalocket on 7/6/20.
//  Copyright © 2020 bermudalocket. All rights reserved.
//

import Combine
import SwiftUI

struct PopoverView: View {

    @EnvironmentObject private var appState: AppState

    @StateObject private var updateHelper: UpdateHelper = UpdateHelper()

    var body: some View {
        VStack(spacing: 10) {
            TitleView()
                .padding(.vertical)
                .background(SectionBackgroundView())

            FeaturesListView()
                .environmentObject(appState)
                .padding(.horizontal)
                .background(SectionBackgroundView())
                .frame(alignment: .top)

            if appState.features[.customSubredditBar] ?? false {
                FavoriteSubredditsSectionView()
                    .padding()
                    .background(SectionBackgroundView())
            }

            SettingsView()
                .padding(.horizontal)
                .background(SectionBackgroundView())

            HStack {
                if updateHelper.isCheckingForUpdate {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .controlSize(.small)
                        .padding(5)
                } else {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
                VStack(alignment: .leading) {
                    Text(updateHelper.isCheckingForUpdate ? "Checking for update..." : "You're up to date")
                        .bold()
                        .font(.callout)
                    if !updateHelper.isCheckingForUpdate {
                        Text(updateHelper.lastCheckedForUpdate)
                            .font(.footnote)
                    }
                }
                .foregroundColor(.gray)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                updateHelper.pollUpdate(forced: true)
            }
        }
        .padding(10)
        .frame(width: 300, alignment: .top)
        .onAppear {
            updateHelper.pollUpdate()
        }
        .alert(isPresented: $updateHelper.updateIsAvailable) {
            Alert(title: Text("An update is available!"))
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopoverView()
                .environmentObject(AppState())
        }
    }
}
