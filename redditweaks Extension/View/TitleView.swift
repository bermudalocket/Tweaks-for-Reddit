//
//  TitleView.swift
//  redditweaks
//
//  Created by Michael Rippe on 3/2/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct TitleView: View {

    @State private var isIconAnimating = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Tweaks for Reddit")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.heavy)
                Text("Version \(Redditweaks.version)")
                    .font(.subheadline)
            }
            .padding(.leading)
            Image("Icon")
                .rotation3DEffect(
                    .init(degrees: isIconAnimating ? 45 : -45),
                    axis: (x: isIconAnimating ? -1 : 1,
                           y: isIconAnimating ? 1 : -1,
                           z: isIconAnimating ? 1 : 0)
                )
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isIconAnimating)
                .scaleEffect(0.8)
                .animation(nil)
                .padding(.trailing)
        }
        .onAppear { self.isIconAnimating.toggle() }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}
