//
//  MacDevicesSymbol.swift
//  Tweaks for Reddit
//
//  Created by Michael Rippe on 9/15/21.
//  Copyright © 2021 bermudalocket. All rights reserved.
//

import SwiftUI

struct MacDevicesSymbol: View {
    var body: some View {
        ZStack {
            Image(systemName: "laptopcomputer")
                .offset(x: -10, y: 7.5)
            Image(systemName: "laptopcomputer")
                .offset(x: 0, y: -7.5)
            Image(systemName: "laptopcomputer")
                .offset(x: 10, y: 7.5)
        }
    }
}

struct MacDevicesSymbol_Previews: PreviewProvider {
    static var previews: some View {
        MacDevicesSymbol()
            .padding()
            .frame(width: 50, height: 50)
    }
}
