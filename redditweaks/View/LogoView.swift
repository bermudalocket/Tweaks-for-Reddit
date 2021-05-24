//
//  LogoView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/15/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct LogoView: View {

    @State private var isIconAnimating = false

    var body: some View {
        VStack(alignment: .center) {
            Image("Icon")
                .rotation3DEffect(
                    .init(degrees: isIconAnimating ? 45 : -45),
                    axis: (x: isIconAnimating ? -1 : 1,
                           y: isIconAnimating ? 1 : -1,
                           z: isIconAnimating ? 1 : 0)
                )
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: isIconAnimating)
            Text("Tweaks for Reddit")
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) {
                isIconAnimating.toggle()
            }
        }
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
