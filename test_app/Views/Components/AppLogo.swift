//
//  AppLogo.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/2/25.
//

import SwiftUI

struct AppLogo: View {
    var iconSize: CGFloat = 50
    var fontSize: CGFloat = 40
    var iconName: String = "App Icon Black"

    var body: some View {
        HStack(spacing: 8) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            Text("SkySniffer")
                .font(.custom("EBGaramond-SemiBold", size: fontSize))
        }
    }
}

#Preview {
    AppLogo()
}
