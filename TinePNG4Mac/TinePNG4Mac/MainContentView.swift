//
//  ContentView.swift
//  TinePNG4Mac
//
//  Created by 张铎 on 2024/11/16.
//

import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var appContext: AppContext
    @StateObject var vm: MainViewModel = MainViewModel()
    @State var dropResult: [URL] = []

    var body: some View {
        ZStack {
            DropFileView(dropResult: $dropResult)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.blue)

            Text("count: \(dropResult.count)")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue)

//            Button {
//                print("click")
//            } label: {
//                Text("click!")
//            }

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
    MainContentView()
}
