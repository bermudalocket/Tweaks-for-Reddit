//
//  FeaturesListView.swift
//  redditweaks
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct FeaturesListView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        DisclosureGroup(isExpanded: appState.$isFeaturesListExpanded) {
            VStack(alignment: .leading) {
                ForEach(appState.features.keys.lazy.compactMap { $0 }.sorted { $0 < $1 }, id: \.self) { feature in
                    Toggle(feature.description, isOn: appState.bindingForFeature(feature))
                }
            }.padding(.bottom)
        } label: {
            HStack {
                Text("Features")
                    .bold()
                Spacer()
            }
            .padding(5)
            .contentShape(Rectangle())
            .onTapGesture {
                appState.isFeaturesListExpanded.toggle()
            }
        }
    }

}

struct FeaturesListView_Previews: PreviewProvider {
    static var previews: some View {
        FeaturesListView()
            .environmentObject(AppState())
            .frame(width: 300)
    }
}
