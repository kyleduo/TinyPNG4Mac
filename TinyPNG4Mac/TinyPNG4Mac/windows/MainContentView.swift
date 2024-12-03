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
    @State private var showRestoreAllConfirmAlert = false

    var body: some View {
        ZStack {
            DropFileView(dropResult: $dropResult)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("mainViewBackground"))

            VStack(spacing: 0) {
                Text("TinyPNG for macOS")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color("textMainTitle"))
                    .frame(height: 28)

                if vm.tasks.isEmpty {
                    Text("Drag and drop images or folder.")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color("textBody"))
                        .frame(idealWidth: 360, maxWidth: .infinity, idealHeight: 360, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(vm.tasks.indices, id: \.self) { index in
                            TaskRowView(vm: vm, task: $vm.tasks[index], last: index == vm.tasks.count - 1)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .clipped()
                    .frame(maxWidth: appContext.maxSize.width)
                    .scrollContentBackground(.hidden)
                    .listStyle(PlainListStyle())
                    .environment(\.defaultMinListRowHeight, 0)
                }

                HorizontalDivider()
                    .padding(vertical: 0, horizontal: 12)
                    .padding(.top, 2)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total: \(vm.tasks.count) tasks, \(vm.totalOriginSize.formatBytes())")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("textSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Completed: \(vm.completedTaskCount) tasks, \(vm.totalFinalSize.formatBytes())")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("textSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        let usedQuota = vm.monthlyUsedQuota >= 0 ? String(vm.monthlyUsedQuota) : "--"
                        Text("Monthly compression count: \(usedQuota)")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("textSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                    }

                    Menu {
                        Button {
                            vm.retryAllFailedTask()
                        } label: {
                            Text("Retry all failed")
                        }
                        .disabled(vm.failedTaskCount == 0)

                        Divider()

                        Button {
                            vm.clearAllTask()
                        } label: {
                            Text("Clear all")
                        }
                        .disabled(vm.tasks.count == 0)

                        Button {
                            vm.clearFinishedTask()
                        } label: {
                            Text("Clear all finished")
                        }
                        .disabled(vm.tasks.count == 0)

                        Divider()

                        Button {
                            showRestoreAllConfirmAlert = true
                        } label: {
                            Text("Restore all completed")
                        }
                        .disabled(vm.completedTaskCount == 0)
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 20, height: 20)
                    }
                    .menuStyle(.borderlessButton)
                    .menuIndicator(.hidden)
                    .frame(width: 20, height: 20)
                    .tint(Color("textSecondary"))
                }.padding(EdgeInsets(top: 8, leading: 12, bottom: 12, trailing: 12))
            }
        }
        .ignoresSafeArea()
        .onChange(of: dropResult) { newValue in
            if !newValue.isEmpty {
                dropResult = []
                vm.createTasks(imageURLs: newValue)
            }
        }
        .alert("Would you like to restore the image?",
               isPresented: Binding(
                   get: { vm.restoreConfirmTask != nil },
                   set: { if !$0 { } }
               ),
               actions: {
                   Button("Confirm") { vm.restoreConfirmConfirmed() }
                   Button("Cancel", role: .cancel) { vm.restoreConfirmCancel() }
               },
               message: {
                   let path = vm.restoreConfirmTask == nil ? "" : vm.restoreConfirmTask?.originUrl.rawPath() ?? ""
                   Text("Image at \"\(path)\" will be restore with origin image file.")
                       .font(.system(size: 12))
               }
        )
        .alert("Config is not ready.",
               isPresented: Binding(
                   get: { vm.settingsNotReadyMessage != nil },
                   set: { if !$0 { vm.settingsNotReadyMessage = nil } }
               ),
               actions: {
                   settingButton(title: "Open Setting")
                   Button("Cancel", role: .cancel) { }
               },
               message: {
                   if let message = vm.settingsNotReadyMessage {
                       Text(message)
                   }
               }
        )
        .alert("Confirm to restore all images?",
               isPresented: $showRestoreAllConfirmAlert,
               actions: {
                   Button("Restore") {
                       vm.restoreAll()
                   }
                   Button("Cancel", role: .cancel) { }
               },
               message: {
                   Text("This operation can not be undone.")
               }
        )
        .alert("Do you really whant to quit?",
               isPresented: $vm.showQuitWithRunningTasksAlert,
               actions: {
                   Button("Quit") {
                       vm.cancelAllTask()
                       NSApplication.shared.terminate(nil)
                   }
                   Button("Cancel", role: .cancel) {}
               },
               message: {
                   Text("There're running tasks, quit app will cancel all the tasks.")
               })
    }

    private func settingButton(title: String) -> some View {
        if #available(macOS 14.0, *) {
            AnyView(
                SettingsLink {
                    Text(title)
                }
            )
        } else {
            AnyView(
                Button {
                    if #available(macOS 13.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                } label: {
                    Text(title)
                }
            )
        }
    }
}
