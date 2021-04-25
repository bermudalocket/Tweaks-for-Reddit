//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var selectedTab: SelectedTab?

    init(tab: SelectedTab = .welcome) {
        self.selectedTab = tab
    }
}

struct MainView: View {

    @EnvironmentObject private var state: AppState

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
            .environmentObject(AppState())
    }
}
