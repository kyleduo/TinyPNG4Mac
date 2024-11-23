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
    @State private var dropResult: [URL] = []
    @State private var showAlert = false
    @State private var showOpenPanel = false

    var body: some View {
        ZStack {
            
            DropFileView(dropResult: $dropResult)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("303030"))

//            Text("count: \(vm.tasks.count)")
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background(Color.blue)

            VStack(spacing: 0) {
                Text("TinyPNG for macOS")
                    .frame(height: appContext.windowTitleBarHeight)
                
                List {
                    ForEach(vm.tasks.indices, id: \.self) { index in
                        let task = vm.tasks[index]
                        TaskRowView(task: task)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 12, bottom: 2, trailing: 12))
                    }
                }
                .padding(.horizontal, -8)
                .frame(maxWidth: 500)
                .scrollContentBackground(.hidden)
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 0)
            }
        }
        .ignoresSafeArea()
        .onChange(of: dropResult) { newValue in
            if !newValue.isEmpty {
                dropResult = []
                vm.createTasks(imageURLs: newValue)
            }
        }
    }

//    private func requestFilePermission() {
//        print("requestFilePermission")
//        
//        let openPanel = NSOpenPanel()
//        openPanel.canChooseFiles = false
//        openPanel.canChooseDirectories = true
//        openPanel.allowsMultipleSelection = false
//        openPanel.prompt = "Select Directory"
//        openPanel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
//        
//        openPanel.begin { result in
//            if result == .OK, let url = openPanel.url {
//                print("User granted access to: \(url.path)")
//                if url.startAccessingSecurityScopedResource() {
//                    print(url)
//                    url.stopAccessingSecurityScopedResource()
//                }
//            } else {
//                print("User did not grant access.")
//            }
//        }
//    }
}

#Preview {
    MainContentView()
}
