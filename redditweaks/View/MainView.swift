//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct DestinationView: View {

    let tab: SelectedTab

    var body: some View {
        Group {
            switch tab {
                case .connectToSafari:
                    ConnectToSafariView()
                        .environmentObject(OnboardingEnvironment())

                case .liveCommentPreview:
                    InAppPurchasesView()
                        .environmentObject(IAPHelper.shared)

                case .welcome:
                    WelcomeView()

                case .iCloud:
                    iCloudView()

                case .toolbar:
                    SafariPopoverView()

                case .debug:
                    DebugView()
                        .environmentObject(IAPHelper.shared)
            }
        }
        .transition(.slide.animation(.linear))
    }
}

struct MainView: View {

    @EnvironmentObject private var state: MainAppState

    @State private var selectedTab: SelectedTab? = .welcome

    var body: some View {
        NavigationView {
            VStack {
                LogoView()
                    .padding(.top, 30)
                List {
                    ForEach(SelectedTab.allCases.indices, id: \.self) { i in
                        let tab = SelectedTab.allCases[i]
                        NavigationLink(
                            destination: DestinationView(tab: tab),
                            tag: tab,
                            selection: $selectedTab,
                            label: {
                                Label {
                                    Text(tab.name)
                                        .font(.title3)
                                } icon: {
                                    Image(systemName: "\(i+1).circle")
                                        .font(.title2)
                                        .padding(10)
                                }
                            })
                            .accentColor(.redditOrange)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 240)
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(width: 825, height: 450)
        .transition(.slide.animation(.linear))
        .onAppear {
            self.selectedTab = state.selectedTab
        }
        .onDisappear {
            state.selectedTab = self.selectedTab ?? .welcome
        }
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(MainAppState())
            .accentColor(.redditOrange)
    }
}
