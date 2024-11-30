//
//  ContentView.swift
//  TinyPNG4Mac
//
//  Created by kyleduo on 2024/11/16.
//

import SwiftUI

struct MainContentView: View {
    @EnvironmentObject var appContext: AppContext
    @ObservedObject var vm: MainViewModel
    @State private var dropResult: [URL] = []
    @State private var showAlert = false
    @State private var showOpenPanel = false
    @State private var bottomAreaShown = false

    var body: some View {
        ZStack {
            DropFileView(dropResult: $dropResult)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("mainViewBackground"))

            if vm.tasks.isEmpty {
                Text("Drag and drop images or folder.")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack(spacing: 0) {
                Text("TinyPNG for macOS")
                    .frame(height: appContext.windowTitleBarHeight)

                List {
                    ForEach(vm.tasks.indices, id: \.self) { index in
                        TaskRowView(vm: vm, task: $vm.tasks[index], last: index == vm.tasks.count - 1)
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

                if bottomAreaShown {
                    HorizontalDivider()
                        .padding(vertical: 0, horizontal: 12)
                        .padding(.top, 2)

                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total: \(vm.tasks.count) tasks, \(vm.totalOriginSize.formatBytes())")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Completed: \(vm.completedTaskCount) tasks, \(vm.totalFinalSize.formatBytes())")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            let usedQuota = vm.monthlyUsedQuota >= 0 ? String(vm.monthlyUsedQuota) : "--"
                            Text("Monthly compression count: \(usedQuota)")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.white.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Spacer()
                            .frame(width: 44)
                    }.padding(EdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12))
                        .frame(maxWidth: 500)
                }
            }

            ZStack(alignment: .bottomTrailing) {
                Color.clear

                Menu {
                    Button {
                        vm.retryAllFailedTask()
                    } label: {
                        Text("Retry all")
                    }
                    .disabled(vm.failedTaskCount == 0)

                    Button {
                        vm.clearAllTask()
                    } label: {
                        Text("Clear all")
                    }
                    .disabled(vm.tasks.count == 0)

                    Button {
                        vm.clearFinishedTask()
                    } label: {
                        Text("Clear completed")
                    }
                    .disabled(vm.tasks.count == 0)

                    Divider()

                    if #available(macOS 14.0, *) {
                        SettingsLink {
                            Text("Settings...")
                        }
                    } else {
                        Button {
                            if #available(macOS 13.0, *) {
                                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                            } else {
                                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                            }
                        } label: {
                            Text("Settings...")
                        }
                    }

                    Button {
                    } label: {
                        Text("Quit")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 12, weight: .medium))
                        .frame(width: 20, height: 20)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 20, height: 20)
                .tint(Color("textSecondary"))
            }
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
        .onChange(of: dropResult) { newValue in
            if !newValue.isEmpty {
                dropResult = []
                vm.createTasks(imageURLs: newValue)
            }
        }
        .onChange(of: vm.tasks.count) { newValue in
            if !bottomAreaShown && newValue > 0 {
                withAnimation {
                    bottomAreaShown = true
                }
            } else if bottomAreaShown && newValue == 0 {
                withAnimation {
                    bottomAreaShown = false
                }
            }
        }
        .alert("Would you like to restore the image?", isPresented: Binding(
            get: { vm.restoreConfirmTask != nil },
            set: { if !$0 { } }
        )) {
            Button("Confirm") { vm.restoreConfirmConfirmed() }
            Button("Cancel", role: .cancel) { vm.restoreConfirmCancel() }
        } message: {
            let path = vm.restoreConfirmTask == nil ? "" : vm.restoreConfirmTask?.originUrl.rawPath() ?? ""
            Text("Image at \"\(path)\" will be restore with origin image file.")
                .font(.system(size: 12))
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
