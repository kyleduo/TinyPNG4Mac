//
//  ContentView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
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
                .background(Color("mainViewBackground"))

            if vm.tasks.isEmpty {
                Text("Drag and drop images or folder.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack(spacing: 0) {
                Text("TinyPNG for macOS")
                    .frame(height: appContext.windowTitleBarHeight)

                if vm.monthlyUsedQuota >= 0 {
                    Text("Monthly compression count: \(vm.monthlyUsedQuota)")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(vertical: 2, horizontal: 12)
                }

                List {
                    ForEach(vm.tasks.indices, id: \.self) { index in
                        let task = $vm.tasks[index]
                        TaskRowView(task: task, first: index == 0, last: index == vm.tasks.count - 1)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                    }
                }
                .clipped()
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
