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

    @State private var isIconAnimating = false

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    Image("Icon")
//                        .rotation3DEffect(
//                            .init(degrees: isIconAnimating ? 45 : -20),
//                            axis: (x: isIconAnimating ? -1 : 1,
//                                   y: isIconAnimating ? 1 : -1,
//                                   z: isIconAnimating ? 1 : 0)
//                        )
//                        .onAppear {
//                            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
//                                isIconAnimating.toggle()
//                            }
//                        }
                    Text("Tweaks for Reddit")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                }.padding(.top, 30)
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
                .animation(nil)
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
