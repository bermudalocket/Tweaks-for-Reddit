//
//  ArtPopoverView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/23/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import SwiftUI

struct ArtPopoverView: View {

    func randomString() -> String {
        Array.init(repeating: "a", count: .random(in: 10...35)).joined()
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                ForEach(1...6, id: \.self) { _ in
                    Toggle(isOn: .constant(.random()), label: {
                        Text(randomString())
                    }).redacted(reason: .placeholder)
                }
            }
        }
    }
}

struct ArtPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        ArtPopoverView()
    }
}
