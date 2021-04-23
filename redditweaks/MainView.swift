//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

class MainViewState: ObservableObject {
    @Published var selectedTab: SelectedTab?

    init(tab: SelectedTab = .welcome) {
        self.selectedTab = tab
    }
}

struct MainView: View {

    @EnvironmentObject private var state: MainViewState

    var body: some View {
        NavigationView {
            VStack {
                Text("Tweaks for Reddit")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .padding(.top)
                List {
                    ForEach(SelectedTab.allCases, id: \.self) { tab in
                        NavigationLink(
                            destination: tab.view,
                            tag: tab,
                            selection: $state.selectedTab,
                            label: { tab.label })
                    }
                }
                    .listStyle(SidebarListStyle())
                    .frame(width: 240)
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(width: 750, height: 450)
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

enum SelectedTab: String, CaseIterable {
    case welcome = "Welcome"
    case connectToSafari = "Connect to Safari"
    case toolbar = "The Toolbar Popover"
    case liveCommentPreview = "Live Comment Previews"

    var name: String {
        self.rawValue
    }

    var icon: String {
        switch self {
            case .welcome: return "1.circle"
            case .connectToSafari: return "2.circle"
            case .toolbar: return "3.circle"
            case .liveCommentPreview: return "star.fill"
        }
    }

    var label: Label<Text, Image> {
        Label {
            Text(self.name)
        } icon: {
            Image(systemName: self.icon)
        }
    }

    var view: some View {
        Group {
            switch self {
                case .connectToSafari:
                    ConnectToSafariView()
                        .environmentObject(OnboardingEnvironment())

                case .liveCommentPreview:
                    InAppPurchases()

                case .welcome:
                    VStack {
                        Spacer()
                        Text("Welcome to ")
                        Text("Tweaks for Reddit")
                            .font(.system(size: 28, weight: .heavy, design: .rounded))
                            .padding(.bottom)
                        Text("Use the menu to the left to set up Tweaks for Reddit\nand explore some of its features.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        Spacer()
                    }

                case .toolbar:
                    VStack {
                        PageView(icon: "bubble.middle.top",
                                 title: "The Popover",
                                 text: "The extension can be accessed in Safari via the toolbar.")
                        SafariToolbarView()
                    }
            }
        }
    }
}
