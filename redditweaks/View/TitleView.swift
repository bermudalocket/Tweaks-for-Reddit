//
//  TitleView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI
import Tweaks_for_Reddit_Core

struct TitleView: View {

    var body: some View {
        VStack {
            Text("Tweaks for Reddit")
                .font(.system(.title, design: .rounded))
                .fontWeight(.heavy)
            Text("Version \(Redditweaks.version)")
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
