////
//  Divider.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/27.
//

import SwiftUI

struct HorizontalDivider: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.black.opacity(0.14))
                .frame(height: 1)
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity)
    }
}
