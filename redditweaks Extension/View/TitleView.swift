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
                Text("Version \(Redditweaks.version)")
                    .font(.subheadline)
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
