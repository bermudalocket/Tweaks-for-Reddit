//
//  TitleView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct TitleView: View {

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    
    var body: some View {
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
                            $0 ? NSCursor.pointingHand.push() : NSCursor.pop()
                        }
                }
            }
            Spacer()
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
