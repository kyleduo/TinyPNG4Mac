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

            Text("count: \(vm.tasks.count)")
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
        .onChange(of: dropResult) { _, newValue in
            vm.createTasks(imageURLs: newValue)
        }
        .onChange(of: vm.requestPermission) { oldValue, newValue in
            if oldValue == false && newValue == true {
                vm.requestPermission = false
                requestFilePermission()
            }
        }
    }
    
    private func requestFilePermission() {
        DispatchQueue.main.async {
            let openPanel = NSOpenPanel()
            openPanel.canChooseFiles = false
            openPanel.canChooseDirectories = true
            openPanel.allowsMultipleSelection = false
            openPanel.prompt = "Select Directory"
            
            openPanel.begin { result in
                if result == .OK, let url = openPanel.url {
                    print("User granted access to: \(url.path)")
                    if url.startAccessingSecurityScopedResource() {
                        print(url)
                        url.stopAccessingSecurityScopedResource()
                    }
                } else {
                    print("User did not grant access.")
                }
            }
        }
    }
}

#Preview {
    MainContentView()
}
