//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationView {
            VStack {
                LogoView()
                    .padding(.top, 30)
                List {
                    ForEach(SelectedTab.allCases, id: \.self) { tab in
                        NavigationLink(
                            destination: tab.view,
                            tag: tab,
                            selection: $state.selectedTab,
                            label: { Text(tab.name).font(.title3) })
                            .padding(10)
                    }
                }
                .listStyle(SidebarListStyle())
                .frame(width: 240)
            }
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(width: 825, height: 450)
        .transition(.slide.animation(.linear))
    }

}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppState())
    }
}
