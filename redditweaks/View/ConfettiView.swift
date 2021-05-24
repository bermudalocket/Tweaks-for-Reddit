//
//  ConfettiView.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 5/21/21.
//  Copyright © 2021 Michael Rippe. All rights reserved.
//

import Foundation
import SwiftUI
import ConfettiSwiftUI

struct ConfettiView: View {

    @State private var confettiCount = 0

    var body: some View {
        ConfettiCannon(counter: $confettiCount, num: 50, confettis: [
            .text("🥳"), .text("🔧")
        ], confettiSize: 30, fadesOut: false)
            .onAppear {
                confettiCount += 1
            }
    }
}

struct ConfettiViewPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            InAppPurchasesView()
                .environmentObject(IAPHelper.shared)
            ConfettiView()
        }
    }
}
