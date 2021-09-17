//
//  VersionView.swift
//  VersionView
//
//  Created by Michael Rippe on 9/13/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI
import TFRCore

struct VersionView: View {
    var body: some View {
        Text("Tweaks for Reddit v\(TweaksForReddit.version)")
            .bold()
            .foregroundColor(Color(.textColor))
            .opacity(0.33)
    }
}

@available(macOS 12, *)
struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VersionView()
            VersionView()
                .preferredColorScheme(.dark)
        }
        .padding()
    }
}
