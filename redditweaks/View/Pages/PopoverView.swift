//
//  PageView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 4/19/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct PopoverView: View {
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Image(systemName: "bubble.middle.top")
                    .font(.system(size: 68))
                    .foregroundColor(.accentColor)
                Text("The Popover")
                    .font(.system(size: 32, weight: .bold))
            }
            .padding(.horizontal)

            VStack(spacing: 12) {
                Text("The extension can be accessed in Safari via the toolbar.")
                Text("From there, you can enable individual features via their checkboxes.")
            }

            ArtSafariToolbarView()
                .padding(.vertical)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverView()
    }
}
