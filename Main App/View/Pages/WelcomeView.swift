//
//  WelcomeView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to")
                .font(.title2)
            Text("Tweaks for Reddit")
                .font(.title)
                .fontWeight(.heavy)
            NextTabButton().padding()
            Spacer()
        }.accessibilityLabel("Welcome to Tweaks for Reddit")
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .frame(width: 500)
    }
}
