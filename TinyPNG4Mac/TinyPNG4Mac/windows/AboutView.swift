////
//  AboutView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/4.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Image("appIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)

                paragraph(text: "\"Slim Image\" (TinyPNG4Mac) is a 3rd-party client for [TinyPNG](https://tinypng.com).")
                    .padding(.top, 16)

                paragraph(text: "TinyPNG holds the final right of interpretation regarding the image compression functionality and results.")

                Spacer()
                    .frame(height: 8)
            }
            .frame(maxHeight: .infinity)

            Text("Made by [@kyleduo](https://github.com/kyleduo)  ❤︎  Open-sourced on [Github](https://github.com/kyleduo/TinyPNG4Mac)")
                .font(.system(size: 12))
                .foregroundStyle(Color("textSecondaryAbout"))
                .padding(.bottom, 12)
        }
        .padding(24)
        .frame(width: 440, height: 360)
    }

    func paragraph(text: LocalizedStringKey) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(Color("textBodyAbout"))
            .multilineTextAlignment(.center)
    }
}

#Preview {
    AboutView()
}
