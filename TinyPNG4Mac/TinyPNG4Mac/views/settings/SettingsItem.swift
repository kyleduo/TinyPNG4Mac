////
//  SettingsItem.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/12/1.
//


import SwiftUI

struct SettingsItem<Content: View>: View {
    var title: LocalizedStringKey
    var desc: LocalizedStringKey?
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .frame(width: 120, alignment: .leading)

            VStack(alignment: .leading) {
                content()

                if let desc = self.desc {
                    Text(desc)
                        .font(.system(size: 10))
                        .padding(.bottom, 8)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: 320, alignment: .leading)
        }
        .padding(.leading, 8)
        .padding(.bottom, 8)
    }
}


//#Preview {
//    SettingsItem(title: "Preserve:", desc: "") {
//        VStack(alignment: .leading) {
//            Toggle("Copyright", isOn: Binding(get: { false }, set: { _ in }))
//            Toggle("Creation", isOn: Binding(get: { false }, set: { _ in }))
//            Toggle("Location", isOn: Binding(get: { false }, set: { _ in }))
//        }
//    }
//}

