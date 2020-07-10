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

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .foregroundColor(Color(.controlBackgroundColor))
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("redditweaks")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                Spacer()
            }
            Text("v\(self.version)")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .padding(.top, 4)
        .background(sectionBackground)
    }

    private var featuresList: some View {
        VStack(alignment: .leading) {
            ForEach(Feature.mainSectionFeatures, id: \.self) { feature in
                FeatureToggleView(feature: feature)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(sectionBackground)
    }

    var body: some View {
        let view = ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                self.title
                self.featuresList
                FavoriteSubredditsSectionView()
                    .padding()
                    .background(sectionBackground)
                Spacer()
            }
            .padding()
        }
        .frame(width: 300, height: 500)
        return Group {
            if #available(OSXApplicationExtension 10.16, *) {
                view.accentColor(.accentColor)
            } else {
                view
            }
        }
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
