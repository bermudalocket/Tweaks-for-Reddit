//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @AppStorage("selectedTab") private var selectedTab: SelectedTab = .welcome

    var body: some View {
        NavigationView {
            VStack {
                TitleView()
                    .padding(.top, 30)
                List(SelectedTab.allCases, id: \.self) { tab in
                    NavigationLink(
                        destination: RoutingView(tab: tab),
                        tag: tab,
                        selection: .init(get: { selectedTab }, set: { selectedTab = $0 ?? .welcome })
                    ) {
                        Text(tab.name)
                            .font(.title3)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 240)
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(width: 825, height: 450)
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
