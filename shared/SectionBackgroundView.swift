//
//  SectionBackgroundView.swift
//  redditweaks
//
//  Created by Michael Rippe on 2/25/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct SectionBackgroundView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.white)
            .opacity(0.3)
            .shadow(radius: 5)
    }
}

struct SectionBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        SectionBackgroundView()
    }
}
