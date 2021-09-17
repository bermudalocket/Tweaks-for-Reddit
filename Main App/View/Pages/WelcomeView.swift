//
//  WelcomeView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    @State private var isAnimating = false

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "hand.wave.fill")
                .resizable()
                .rotationEffect(Angle.init(degrees: isAnimating ? 0 : 30), anchor: .bottomTrailing)
                .scaledToFit()
                .frame(width: 50)
                .foregroundColor(.redditOrange)
            Text("Welcome to")
                .font(.title2)
                .onAppear {
                    withAnimation(.linear(duration: 1).delay(0.5).repeatForever()) {
                        self.isAnimating = true
                    }
                }
            Text("Tweaks for Reddit")
                .font(.title)
                .fontWeight(.heavy)

            Text("The next few pages will guide you through setting up the app.")
                .padding(.vertical)

            NextTabButton()
                .padding()
            Spacer()
        }
        .accessibilityLabel("Welcome to Tweaks for Reddit")
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .frame(width: 500)
    }
}
