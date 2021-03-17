//
//  SectionBackgroundView.swift
//  redditweaks
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct SectionBackgroundView: View {

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(.textBackgroundColor))
            .opacity(colorScheme == .light ? 0.3 : 0.7)
            .shadow(radius: 5)
    }
    
}

struct SectionBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SectionBackgroundView()
    }
}
