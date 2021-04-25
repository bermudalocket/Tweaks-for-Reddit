//
//  PageView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/19/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct PageView: View {

    let icon: String
    let title: String
    let text: String

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 72))
                    .foregroundColor(.blue)
                Text(title)
                    .font(.system(size: 32, weight: .bold))
            }
            .padding()

            VStack(spacing: 12) {
                Text(text)
                    .multilineTextAlignment(.center)
            }

        }
        .padding()
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(icon: "safari", title: "Connect to Safari", text: "Test")
    }
}
