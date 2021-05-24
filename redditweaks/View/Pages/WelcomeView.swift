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
                .font(.system(size: 32, weight: .heavy, design: .rounded))
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
