//
//  MainView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/17/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct MainView: View {

    @EnvironmentObject private var store: MainAppStore

    var body: some View {
        NavigationView {
            VStack {
                TitleView()
                    .padding(.top, 30)
                List(SelectedTab.allCases, id: \.self) { tab in
                    NavigationLink(
                        destination: tab.view,
                        tag: tab,
                        selection: store.binding(for: \.tab, transform: MainAppAction.setTab)
                    ) {
                        HStack {
                            Image(systemName: tab.symbol)
                                .renderingMode(.original)
                                .frame(width: 25)
                            Text(tab.name)
                        }
                        .font(.title3)
                        .accessibilityLabel(tab.name)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(width: 240)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        .frame(width: 825, height: 450)
    }

}

import TFRCore

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(
                MainAppStore(
                    initialState: MainAppState(),
                    reducer: .none,
                    environment: .shared
                )
            )
    }
}
