//
//  ContentView.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appContext: AppContext
        
    var body: some View {
        ZStack {
            DropFileView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)
            
//            Text("Hello")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.blue)
            
            VStack {
                Text("TinyPNG for macOS")
                    .frame(height: appContext.windowTitleBarHeight)
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
