//
//  TitleView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct TitleView: View {

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Text("Tweaks for Reddit")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.heavy)
                HStack {
                    Text("Version \(Redditweaks.version)")
                        .font(.subheadline)
                    if !Redditweaks.isFromMacAppStore {
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
