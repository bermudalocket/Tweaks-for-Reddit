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
            .fill(Color.white)
            .opacity(0.3)
            .shadow(radius: 5)
    }

    private var title: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("redditweaks")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                HStack {
                    Text("Version \(self.version)")
                        .font(.subheadline)
                    Text("Report a bug")
                        .foregroundColor(Color(.linkColor))
                        .underline()
                        .font(.subheadline)
                        .onTapGesture {
                            NSWorkspace.shared.open(Redditweaks.repoURL)
                        }
                        .onHover {
                            if $0 {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                }
            }
            Spacer()
        }
        .padding(.vertical)
        .background(sectionBackground)
    }

    @State private var isFeaturesListExpanded = true

    private var featuresList: some View {
        VStack {
            HStack {
                Text("Features").bold()
                Spacer()
                Image(isFeaturesListExpanded ? "chevron.down" : "chevron.right")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isFeaturesListExpanded.toggle()
                }
            }
            .padding(.horizontal)
            if (isFeaturesListExpanded) {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        ForEach(Feature.mainSectionFeatures, id: \.self) { feature in
                            FeatureToggleView(feature: feature)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(sectionBackground)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            self.title
            self.featuresList
            FavoriteSubredditsSectionView()
                .padding()
                .background(sectionBackground)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(width: 300)
    }
}

struct PopoverView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
